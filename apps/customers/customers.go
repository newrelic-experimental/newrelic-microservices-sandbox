package main

import (
	"database/sql"

	"github.com/gin-gonic/gin"
)

type Contact struct {
	FirstName string `json:"firstName"`
	LastName  string `json:"lastName"`
	Email     string `json:"email"`
	Title     string `json:"title"`
}

type Company struct {
	Name    string  `json:"name"`
	Address Address `json:"address"`
}

type Address struct {
	Street     string `json:"street"`
	City       string `json:"city"`
	State      string `josn:"state"`
	PostalCode string `json:"postalCode"`
}

type Customer struct {
	Id      string  `json:"id"`
	Contact Contact `json:"contact"`
	Company Company `json:"company"`
}

func getCustomer(db *sql.DB) func(c *gin.Context) {

	return func(c *gin.Context) {
		id := c.Param("id")
		stmtOut, err := db.Prepare("SELECT * FROM customers WHERE id = ?")
		if err != nil {
			c.JSON(500, gin.H{
				"message": err.Error(),
			})
		}
		defer stmtOut.Close()

		var customer Customer

		// Query the square-number of 13
		err = stmtOut.QueryRow(id).Scan(&customer.Id, &customer.Contact.FirstName, &customer.Contact.LastName, &customer.Contact.Email, &customer.Contact.Title, &customer.Company.Name, &customer.Company.Address.Street, &customer.Company.Address.City, &customer.Company.Address.State, &customer.Company.Address.PostalCode)
		if err != nil {
			if err == sql.ErrNoRows {
				c.JSON(404, gin.H{
					"message": "customer not found",
				})
			} else {
				c.JSON(500, gin.H{
					"message": err.Error(),
				})
			}
			return
		}

		c.JSON(200, customer)
	}

}
