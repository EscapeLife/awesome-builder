# -*- coding: UTF-8 -*-

import time
from locust import HttpUser, constant, events, task
from locust.contrib.fasthttp import FastHttpUser


def transaction(name):
    def decorator(func):
        def wrapper(*args, **kwargs):
            start_time = time.time() * 1000
            func(*args, **kwargs)
            events.request_success.fire(request_type="ALL", name=name, response_time=int(
                time.time() * 1000 - start_time), response_length=0,)
        return wrapper
    return decorator


class LocustTest(FastHttpUser):
    wait_time = constant(0)

    def on_start(self):
        login_json = {"name": "admin", "password": "123456"}
        headers = {'Content-Type': 'application/x-www-form-urlencoded'}
        r = self.client.post("/api/v1/login", json=login_json, headers=headers)
        print(f"[Login]: {r.status_code}")

    @task(1)
    @transaction("desc_info")
    def desc_info(self):
        r = self.client.get("/desc")
        print(f"[Desc]: {r.status_code}")

    @task(2)
    @transaction("view_info")
    def view_info(self):
        r1 = self.client.get("/view")
        r2 = self.client.get("/info/1")
        print(f"[View]: {r1.status_code} - {r2.status_code}")

    def on_stop(self):
        self.client.cookies.clear()
