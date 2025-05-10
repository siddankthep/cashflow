from locust import HttpUser, task, between, events
import json
import uuid
import random

# Custom event to log test start and request failures
@events.test_start.add_listener
def on_test_start(environment, **kwargs):
    print("Starting load test...")

@events.request.add_listener
def on_request(request_type, name, response_time, response_length, exception, **kwargs):
    if exception:
        print(f"Request failed: {name}, Exception: {exception}, Response: {kwargs.get('response').text if kwargs.get('response') else 'No response'}")

class CashflowAPIUser(HttpUser):
    # Wait 1-5 seconds between tasks to simulate user think time
    wait_time = between(1, 5)

    # Host URL (set via --host when running Locust)
    host = "http://localhost:8080"

    # Run once per user at the start
    def on_start(self):
        # Generate unique user data for signup
        self.username = f"user_{uuid.uuid4().hex[:8]}"
        self.email = f"{self.username}@test.com"
        self.password = "123456"
        self.first_name = "Test"
        self.last_name = "User"

        # Signup
        signup_response = self.client.post(
            "/auth/signup",
            json={
                "email": self.email,
                "username": self.username,
                "password": self.password,
                "firstName": self.first_name,
                "lastName": self.last_name
            },
            name="/auth/signup"
        )
        if signup_response.status_code != 200:
            print(f"Signup failed for {self.username}: {signup_response.status_code} - {signup_response.text}")
            return

        # Login to get JWT token
        login_response = self.client.post(
            "/auth/login",
            json={
                "username": self.username,
                "password": self.password
            },
            name="/auth/login"
        )
        if login_response.status_code == 200:
            self.token = login_response.json().get("token")
        else:
            print(f"Login failed for {self.username}: {login_response.status_code} - {login_response.text}")
            self.token = None

    @task(2)  # Weight: Frequent task
    def get_user_info(self):
        if not self.token:
            return
        self.client.get(
            "/users/me",
            headers={"Authorization": f"Bearer {self.token}"},
            name="/users/me"
        )

    @task(1)  # Weight: Less frequent
    def update_balance(self):
        if not self.token:
            return
        # Random balance between 10 and 1000
        balance = random.uniform(10.0, 1000.0)
        self.client.post(
            "/users/me/update_balance",
            json=balance,
            headers={"Authorization": f"Bearer {self.token}"},
            name="/users/me/update_balance"
        )

    @task(1)  # Weight: Less frequent
    def get_transactions(self):
        if not self.token:
            return
        self.client.get(
            "/transactions/",
            headers={"Authorization": f"Bearer {self.token}"},
            name="/transactions"
        )

    @task(1)  # Weight: Less frequent
    def save_transaction(self):
        if not self.token:
            return
        # Sample transaction data
        transaction = {
            "category": {
                "id": "1668e79f-1822-4f20-b24e-5e446222f348",
                "name": "Food & Dining",
                "icon": "restaurant",
                "color": 4294198070,
            },
            "subtotal": random.randint(10000, 1000000),
            "description": "Sample transaction from load test",
            "transactionDate": "2025-05-10",
            "paymentMethod": "Tiền mặt",
            "location": "Test Restaurant, Hanoi"
        }
        self.client.post(
            "/transactions/save",
            json=transaction,
            headers={"Authorization": f"Bearer {self.token}"},
            name="/transactions/save"
        )

    @task(1)  # Weight: Less frequent
    def get_categories(self):
        if not self.token:
            return
        self.client.get(
            "/categories/",
            headers={"Authorization": f"Bearer {self.token}"},
            name="/categories"
        )

    @task(1)  # Weight: Less frequent (simulated OCR scan)
    def ocr_scan(self):
        if not self.token:
            return
        # Simulate image path (replace with actual file path or mock data)
        image_path = "sample_receipt.jpg"
        self.client.post(
            "/ocr/scan",
            json={"imagePath": image_path},
            headers={"Authorization": f"Bearer {self.token}"},
            name="/ocr/scan"
        )