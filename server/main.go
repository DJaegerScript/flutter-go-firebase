package main

import (
	"context"
	"fmt"
	"github.com/gofiber/fiber/v2"
	"google.golang.org/api/idtoken"
	"strings"
)

type user struct {
	Name  string `json:"name"`
	Email string `json:"name"`
}

var users []user

func main() {
	app := fiber.New()

	app.Post("/", func(c *fiber.Ctx) error {
		type request struct {
			Token string `json:"token"`
		}

		var req request

		if err := c.BodyParser(&req); err != nil {
			return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
				"success": false,
				"content": nil,
				"message": err.Error(),
			})
		}

		payload, err := idtoken.Validate(context.Background(), req.Token, "677198952032-meq3mdl2cupp6gp59f1dickf4mrntkh6.apps.googleusercontent.com")
		if err != nil {
			fmt.Println(err)
			return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
				"success": false,
				"content": nil,
				"message": err.Error(),
			})
		}

		currentUser := user{
			Name:  payload.Claims["name"].(string),
			Email: payload.Claims["email"].(string),
		}

		users = append(users, currentUser)

		return c.Status(fiber.StatusOK).JSON(fiber.Map{
			"message": "Congratulations, you've been signed in by Google",
			"content": req.Token,
		})
	})

	app.Get("/", func(c *fiber.Ctx) error {
		authorization := c.Get("Authorization")
		token := strings.Split(authorization, " ")[1]

		payload, err := idtoken.Validate(context.Background(), token, "677198952032-meq3mdl2cupp6gp59f1dickf4mrntkh6.apps.googleusercontent.com")
		if err != nil {
			fmt.Println(err)
			return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
				"success": false,
				"content": nil,
				"message": err.Error(),
			})
		}

		email := payload.Claims["email"].(string)

		var name string

		for _, user := range users {
			if user.Email == email {
				name = user.Name
			}
		}

		return c.Status(fiber.StatusOK).JSON(fiber.Map{
			"message": "Congratulations, you've been signed in by Google",
			"content": name,
		})
	})

	app.Listen(":3000")
}
