package main

import (
	"context"
	"database/sql"
	"fmt"
	"log"
	"os"
	"time"

	"github.com/gin-gonic/gin"
	nrgin "github.com/newrelic/go-agent/v3/integrations/nrgin"
	_ "github.com/newrelic/go-agent/v3/integrations/nrmysql"
	"github.com/newrelic/go-agent/v3/newrelic"
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

	// mysqlConfig := mysql.NewConfig()
	// mysqlConfig.User = getEnv("MYSQL_USERNAME", "root")
	// mysqlConfig.Passwd = getEnv("MYSQL_PASSWORD", "password")
	// mysqlConfig.Net = "tcp"
	// mysqlConfig.Addr = fmt.Sprintf("%s:%s", getEnv("MYSQL_HOST", "localhost"), getEnv("MYSQL_PORT", "3306"))
	// mysqlConfig.DBName = getEnv("MYSQL_DATABASE", "customers")

	// connector, connectorErr := mysql.NewConnector(mysqlConfig)
	// if connectorErr != nil {
	// 	panic(connectorErr)
	// }

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

	router := gin.Default()
	router.Use(nrgin.Middleware(app))

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
