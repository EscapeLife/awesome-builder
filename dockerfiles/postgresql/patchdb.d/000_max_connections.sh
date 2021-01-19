#!/usr/bin/env bash

sed -i "s/max_connections = [0-9]\+/max_connections = ${POSTGRES_MAX_CONNECTIONS:-1000}/g" "${PGDATA}"/postgresql.conf
