package main

import (
	"context"
	"database/sql"
	"fmt"
	"os"
	"time"

	swaggerfiles "github.com/swaggo/files"
	ginSwagger "github.com/swaggo/gin-swagger"

	_ "newrelic-microservices-sandbox/customers/docs"

	"github.com/gin-gonic/gin"
	"github.com/newrelic/go-agent/v3/integrations/logcontext/nrlogrusplugin"
	nrgin "github.com/newrelic/go-agent/v3/integrations/nrgin"
	_ "github.com/newrelic/go-agent/v3/integrations/nrmysql"
	"github.com/newrelic/go-agent/v3/newrelic"
	logrus "github.com/sirupsen/logrus"
	"github.com/toorop/gin-logrus"
)

const NrMysqlCtxKey = "NEW_RELIC_MYSQL_CONTEXT"

func getEnv(name string, defaultValue string) string {
	value, exists := os.LookupEnv(name)
	if exists {
		return value
	} else {
		return defaultValue
	}
}

//Create and return the New Relic Mysql Context
func NewRelicMysqlCtx(c *gin.Context) context.Context {
	txn := nrgin.Transaction(c)
	ctx := newrelic.NewContext(context.Background(), txn)
	return ctx
}

//middleware to set the api version
func ApiVersionAttribute(version string) (apiVersionAttribute func(c *gin.Context)) {
	return func(c *gin.Context) {
		txn := nrgin.Transaction(c)
		txn.AddAttribute("apiVersion", version)
	}
}

func main() {
	log := logrus.New()
	log.SetFormatter(nrlogrusplugin.ContextFormatter{})

	// @title           Customers API
	// @version         2.0
	// @description     endpoints for working with customers and authentication

	app, err := newrelic.NewApplication(
		newrelic.ConfigAppName("Customers Service"),
		newrelic.ConfigLicense(os.Getenv("NEW_RELIC_LICENSE_KEY")),
		newrelic.ConfigDebugLogger(os.Stdout),
		newrelic.ConfigDistributedTracerEnabled(true),
	)
	if nil != err {
		log.Print(err)
	}

	// db := sql.OpenDB(connector)
	connStr := fmt.Sprintf("%s:%s@tcp(%s:%s)/%s", getEnv("MYSQL_USERNAME", "root"), getEnv("MYSQL_PASSWORD", "password"), getEnv("MYSQL_HOST", "localhost"), getEnv("MYSQL_PORT", "3306"), getEnv("MYSQL_DATABASE", "customers"))
	log.Print(fmt.Sprintf("Connecting to %s", connStr))
	db, err := sql.Open("nrmysql", connStr)
	if err != nil {
		panic(err)
	}

	// See "Important settings" section.
	db.SetConnMaxLifetime(time.Minute * 3)
	db.SetMaxOpenConns(10)
	db.SetMaxIdleConns(10)

	// dbErr := db.Ping()
	// if dbErr != nil {
	// 	panic(dbErr.Error())
	// }

	//log.Print("Connected to database")

	router := gin.New()
	router.Use(ginlogrus.Logger(log), gin.Recovery(), nrgin.Middleware(app))
	router.Use(nrgin.Middleware(app))
	router.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerfiles.Handler))

	router.GET("/ping", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"message": "pong",
		})
	})

	v1 := router.Group("/v1")
	{
		v1.Use(ApiVersionAttribute("v1"))
		v1.GET("/customers/:id", getCustomer(db))
		v1.POST("/customers/token", token(db))
		v1.POST("/customers/authorize", authorize(db))
	}

	v2 := router.Group("/v2")
	{
		v2.Use(ApiVersionAttribute("v2"))
		v2.GET("/customers/:id", getCustomer(db))
		v2.POST("/customers/token", token(db))
		v2.POST("/customers/authorize", authorize(db))
	}

	router.Run() // listen and serve on 0.0.0.0:8080 (for windows "localhost:8080")
}
