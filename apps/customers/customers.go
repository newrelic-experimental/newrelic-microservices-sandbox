package main

import (
	"database/sql"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
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
	Id         string  `json:"id"`
	Contact    Contact `json:"contact"`
	Company    Company `json:"company"`
	ApiVersion string  `json:"apiVersion"`
}

// getCustomer godoc
// @Summary      Get a customer by ID
// @Tags         customers
// @Produce      json
// @Param        id   path      string  true  "Customer ID"
// @Success      200  {object}  Customer
// @Router       /customers/{id} [get]
func getCustomer(db *sql.DB) (getCustomer func(c *gin.Context)) {

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

		ctx := NewRelicMysqlCtx(c)
		err = stmtOut.QueryRowContext(ctx, id).Scan(&customer.Id, &customer.Contact.FirstName, &customer.Contact.LastName, &customer.Contact.Email, &customer.Contact.Title, &customer.Company.Name, &customer.Company.Address.Street, &customer.Company.Address.City, &customer.Company.Address.State, &customer.Company.Address.PostalCode, &customer.ApiVersion)
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

type TokenResponse struct {
	Token    string   `json:"token"`
	Customer Customer `json:"customer"`
}

// token godoc
// @Summary      Generate a token
// @Tags		 auth
// @Produce      json
// @Success      200  {object}  TokenResponse
// @Router       /customers/token [post]
func token(db *sql.DB) (token func(c *gin.Context)) {

	return func(c *gin.Context) {

		//get a random customer
		stmtOut, err := db.Prepare("SELECT * FROM customers ORDER BY RAND() LIMIT 1")
		if err != nil {
			c.JSON(500, gin.H{
				"message": err.Error(),
			})
		}
		defer stmtOut.Close()

		var customer Customer

		ctx := NewRelicMysqlCtx(c)
		err = stmtOut.QueryRowContext(ctx).Scan(&customer.Id, &customer.Contact.FirstName, &customer.Contact.LastName, &customer.Contact.Email, &customer.Contact.Title, &customer.Company.Name, &customer.Company.Address.Street, &customer.Company.Address.City, &customer.Company.Address.State, &customer.Company.Address.PostalCode, &customer.ApiVersion)
		if err != nil {
			c.JSON(500, gin.H{
				"message": err.Error(),
			})
			return
		}

		//generate a new token
		token := uuid.New()

		//insert it into the token table
		stmtIns, err := db.Prepare("INSERT INTO tokens VALUES( ?, ? )")
		if err != nil {
			c.JSON(500, gin.H{
				"message": err.Error(),
			})
			return
		}
		defer stmtIns.Close()

		_, err = stmtIns.ExecContext(ctx, token.String(), &customer.Id)
		if err != nil {
			c.JSON(500, gin.H{
				"message": err.Error(),
			})
			return
		}
		tr := TokenResponse{
			Token:    token.String(),
			Customer: customer,
		}
		c.JSON(200, tr)
	}

}

type Authorization struct {
	Token string `json:"token" binding:"required"`
}

type AuthorizationResponse struct {
	CustomerId   string `json:"customerId"`
	CustomerName string `json:"customerName"`
}

// authorize godoc
// @Summary      Authorize based on a token
// @Tags		 auth
// @Param   	 payload   body    Authorization    true  "api token"
// @Produce      json
// @Success      200  {object}  AuthorizationResponse "customer id and name"
// @Router       /customers/authorize [post]
func authorize(db *sql.DB) (authorize func(c *gin.Context)) {

	return func(c *gin.Context) {

		var payload Authorization
		if err := c.ShouldBindJSON(&payload); err != nil {
			c.JSON(400, gin.H{"message": "Bad Request. Could not marshal JSON Payload"})
			return
		}

		stmtOut, err := db.Prepare("SELECT customers.id, customers.company_name FROM customers, tokens WHERE customers.id = tokens.customer_id and tokens.token = ?")
		if err != nil {
			c.JSON(500, gin.H{
				"message": err.Error(),
			})
		}
		defer stmtOut.Close()

		var validCustomerId string
		var validCustomerName string

		ctx := NewRelicMysqlCtx(c)
		err = stmtOut.QueryRowContext(ctx, payload.Token).Scan(&validCustomerId, &validCustomerName)
		if err != nil {
			if err == sql.ErrNoRows {
				c.JSON(403, gin.H{
					"message": "unauthorized",
				})
			} else {
				c.JSON(500, gin.H{
					"message": err.Error(),
				})
			}
			return
		}

		ar := AuthorizationResponse{
			CustomerId:   validCustomerId,
			CustomerName: validCustomerName,
		}
		c.JSON(200, ar)

	}

}
