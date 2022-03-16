package main

import (
	"database/sql"
	"fmt"
	"log"
	"os"
	"time"

	"github.com/gin-gonic/gin"
	_ "github.com/go-sql-driver/mysql"
	nrgin "github.com/newrelic/go-agent/v3/integrations/nrgin"
	"github.com/newrelic/go-agent/v3/newrelic"
)

func getEnv(name string, defaultValue string) string {
	value, exists := os.LookupEnv(name)
	if exists {
		return value
	} else {
		return defaultValue
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
	)
	if nil != err {
		log.Print(err)
	}

	// db := sql.OpenDB(connector)
	connStr := fmt.Sprintf("%s:%s@tcp(%s:%s)/%s", getEnv("MYSQL_USERNAME", "root"), getEnv("MYSQL_PASSWORD", "password"), getEnv("MYSQL_HOST", "localhost"), getEnv("MYSQL_PORT", "3306"), getEnv("MYSQL_DATABASE", "customers"))
	log.Print(fmt.Sprintf("Connecting to %s", connStr))
	db, err := sql.Open("mysql", connStr)
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

	router.GET("/customers/:id", getCustomer(db))

	router.POST("/customers/token", token(db))

	router.POST("/customers/authorize", authorize(db))

	router.Run() // listen and serve on 0.0.0.0:8080 (for windows "localhost:8080")
}
