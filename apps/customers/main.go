package main

import (
	"database/sql"
	"fmt"
	"log"
	"os"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/go-sql-driver/mysql"
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

	mysqlConfig := mysql.NewConfig()
	mysqlConfig.User = getEnv("MYSQL_USERNAME", "root")
	mysqlConfig.Passwd = getEnv("MYSQL_PASSWORD", "password")
	mysqlConfig.Net = "tcp"
	mysqlConfig.Addr = fmt.Sprintf("%s:%s", getEnv("MYSQL_HOST", "localhost"), getEnv("MYSQL_PORT", "3306"))
	mysqlConfig.DBName = getEnv("MYSQL_DATABASE", "customers")

	connector, connectorErr := mysql.NewConnector(mysqlConfig)
	if connectorErr != nil {
		panic(connectorErr)
	}

	db := sql.OpenDB(connector)

	// See "Important settings" section.
	db.SetConnMaxLifetime(time.Minute * 3)
	db.SetMaxOpenConns(10)
	db.SetMaxIdleConns(10)

	dbErr := db.Ping()
	if dbErr != nil {
		panic("Unable to connect to database")
	}

	log.Print("Connected to database")

	router := gin.Default()

	router.GET("/ping", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"message": "pong",
		})
	})

	router.GET("/customer/:id", getCustomer(db))

	router.POST("/customer/token", token(db))

	router.POST("/customer/authorize", authorize(db))

	router.Run() // listen and serve on 0.0.0.0:8080 (for windows "localhost:8080")
}
