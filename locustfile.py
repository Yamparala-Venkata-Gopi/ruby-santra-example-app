from locust import HttpUser, task, between
import random

class SinatraAppUser(HttpUser):
    wait_time = between(1, 5)  # Wait 1-5 seconds between requests
    
    def on_start(self):
        """Called when a user starts"""
        print("Starting load test user...")
    
    @task(5)  # Higher weight - will be called more often
    def view_homepage(self):
        """Visit the homepage"""
        self.client.get("/")
    
    @task(2)
    def visit_google_proxy(self):
        """Visit Google proxy route"""
        self.client.get("/google")
    
    @task(2)
    def visit_amazon_proxy(self):
        """Visit Amazon proxy route"""
        self.client.get("/amazon")
    
    @task(2)
    def visit_walmart_proxy(self):
        """Visit Walmart proxy route"""
        self.client.get("/walmart")
    
    @task(2)
    def visit_nike_proxy(self):
        """Visit Nike proxy route"""
        self.client.get("/nike")
    
    @task(2)
    def visit_github_proxy(self):
        """Visit GitHub proxy route"""
        self.client.get("/github")
    
    @task(1)
    def visit_random_404(self):
        """Generate some 404 traffic"""
        random_paths = [
            "/nonexistent",
            "/random-page",
            "/test-404",
            "/missing-route",
            "/fake-asset.css",
            "/fake-script.js"
        ]
        path = random.choice(random_paths)
        self.client.get(path)
    
    @task(1)
    def simulate_browser_assets(self):
        """Simulate browser requesting assets (will get 404s)"""
        assets = [
            "/favicon.ico",
            "/robots.txt",
            "/sitemap.xml",
            "/css/style.css",
            "/js/app.js"
        ]
        asset = random.choice(assets)
        self.client.get(asset)

class PowerUser(HttpUser):
    """Simulates a power user hitting multiple endpoints quickly"""
    wait_time = between(0.5, 2)
    weight = 1  # Lower weight means fewer of these users
    
    @task
    def rapid_fire_requests(self):
        """Make rapid requests to different endpoints"""
        endpoints = ["/", "/google", "/amazon", "/walmart", "/nike", "/github"]
        endpoint = random.choice(endpoints)
        self.client.get(endpoint)

class SlowUser(HttpUser):
    """Simulates users with slow connections or who read pages slowly"""
    wait_time = between(10, 30)
    weight = 1
    
    @task
    def slow_browsing(self):
        """Slow browsing pattern"""
        # Visit homepage first
        self.client.get("/")
        # Then visit one proxy route
        proxy_routes = ["/google", "/amazon", "/walmart", "/nike", "/github"]
        route = random.choice(proxy_routes)
        self.client.get(route) 