#!/usr/bin/env bash

sed -i "s/^\#\?log_min_duration_statement = .*/log_min_duration_statement = ${POSTGRES_LOG_MIN_DURATION_STATEMENT:-3000}/g" "${PGDATA}"/postgresql.conf
