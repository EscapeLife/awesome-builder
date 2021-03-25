#!/bin/bash

locust --headless --host http://127.0.0.1:8000 \
    -u 100 -r 10 --run-time 30s --stop-timeout 99 -f locust_demo.py
