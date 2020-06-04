#!/usr/bin/env bash

sed -i "s/^\#logging_collector = off/logging_collector = on/g" "${PGDATA}"/postgresql.conf
