from locust import HttpUser, task, between
import random

class SuperHeroesUser(HttpUser):
    wait_time = between(1, 5)

    @task
    def superheroes(self):
        num = random.randint(1, 10)
        randreq = self.client.get(f"/api/superheroes/random?num={num}")
        for superhero in randreq.json():
          slug = f"{superhero['id']}-{superhero['name'].lower().replace(' ', '-')}"
          self.client.get(f"/api/superheroes/slug/{slug}")

    def on_start(self):
        tokenResponse = self.client.post("/api/customers/token")
        body = tokenResponse.json()
        self.customer = body['customer']
        self.token = body['token']
        self.client.headers['X-Superheroes-Api-Key'] = self.token
        self.client.headers['X-Api-Version'] = 'v1' #self.customer['apiVersion']