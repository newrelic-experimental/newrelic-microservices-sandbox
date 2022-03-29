from locust import HttpUser, task, between
import random
import time

class SuperHeroesUser(HttpUser):
    wait_time = between(5, 10)
    
    @task
    def superheroes_by_slug(self):
        num = random.randint(1, 10)
        randreq = self.client.get(f"/api/{self.customer['apiVersion']}/superheroes/random?num={num}", name=f"/api/{self.customer['apiVersion']}/superheroes/random")
        for superhero in randreq.json():
          time.sleep(.5)
          slug = f"{superhero['id']}-{superhero['name'].lower().replace(' ', '-')}"
          self.client.get(f"/api/{self.customer['apiVersion']}/superheroes/slug/{slug}", name=f"/api/{self.customer['apiVersion']}/superheroes/slug/:slug")
          
    @task   
    def superheroes_by_id(self):
        num = random.randint(1, 10)
        randreq = self.client.get(f"/api/{self.customer['apiVersion']}/superheroes/random?num={num}", name=f"/api/{self.customer['apiVersion']}/superheroes/random")
        for superhero in randreq.json():
          time.sleep(.5)
          self.client.get(f"/api/{self.customer['apiVersion']}/superheroes/{superhero['id']}", name=f"/api/{self.customer['apiVersion']}/superheroes/:id")
    
    @task
    def compare(self):
        randreq = self.client.get(f"/api/{self.customer['apiVersion']}/superheroes/random?num=2", name=f"/api/{self.customer['apiVersion']}/superheroes/random")
        shs = randreq.json()
        comparator = random.choice(["intelligence", "strength", "speed", "durability", "power", "combat"])
        key = 'id' if (self.customer['apiVersion'] == 'v2') else 'slug'
        self.client.get(f"/api/v2/superheroes/compare?superhero1={shs[0][key]}&superhero2={shs[1][key]}&comparator={comparator}", name=f"/api/v2/superheroes/compare")

    def on_start(self):
        tokenResponse = self.client.post("/api/v2/customers/token")
        body = tokenResponse.json()
        self.customer = body['customer']
        self.token = body['token']
        self.client.headers['X-Api-Key'] = self.token
        apiClientVersion = "2.0" if (self.customer['apiVersion'] == 'v2') else "1.0"
        self.client.headers['User-Agent'] = f"SuperHeroes-ApiClient/{apiClientVersion}"