from locust import HttpUser, task, between
import random
import time

class SuperHeroesUser(HttpUser):
    wait_time = between(5, 10)
    
    @task
    def superheroes_by_slug(self):
        num = random.randint(1, 10)
        randreq = self.client.get(f"/api/superheroes/random?num={num}")
        for superhero in randreq.json():
          time.sleep(.5)
          slug = f"{superhero['id']}-{superhero['name'].lower().replace(' ', '-')}"
          self.client.get(f"/api/superheroes/slug/{slug}")
          
    @task   
    def superheroes_by_id(self):
        num = random.randint(1, 10)
        randreq = self.client.get(f"/api/superheroes/random?num={num}")
        for superhero in randreq.json():
          time.sleep(.5)
          self.client.get(f"/api/superheroes/{superhero['id']}")
    
    @task
    def compare(self):
        randreq = self.client.get(f"/api/superheroes/random?num=2")
        shs = randreq.json()
        comparator = random.choice(["intelligence", "strength", "speed", "durability", "power", "combat"])
        key = 'id' if (self.v == 'v1') else 'slug'
        self.client.get(f"/api/superheroes/compare?superhero1={shs[0][key]}&superhero2={shs[1][key]}&comparator={comparator}")

    def on_start(self):
        tokenResponse = self.client.post("/api/customers/token")
        body = tokenResponse.json()
        self.customer = body['customer']
        self.token = body['token']
        pct = random.randint(1,100)
        if (pct > 90):
            self.v = 'v2'
        else:
            self.v = 'v1'
        self.client.headers['X-Superheroes-Api-Key'] = self.token
        self.client.headers['X-Api-Version'] = 'v1' #self.customer['apiVersion']