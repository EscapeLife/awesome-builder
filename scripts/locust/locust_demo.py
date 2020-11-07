# -*- coding: UTF-8 -*-

from locust import HttpUser, constant, task


class LocustTest(HttpUser):
    wait_time = constant(0)

    def on_start(self):
        login_json = {"name": "admin", "password": "123456"}
        headers = {'Content-Type': 'application/x-www-form-urlencoded'}
        response = self.client.post("/api/v1/login", json=login_json, headers=headers)
        print(f"[1] Login: {response.status_code}")

    @task(1)
    def desc_info(self):
        response = self.client.get("/desc")
        print(f"[2] Desc: {response.status_code}")

    @task(2)
    def view_item(self):
        response = self.client.get("/view")
        print(f"[3] View: {response.status_code}")

    def on_stop(self):
        self.client.cookies.clear()
