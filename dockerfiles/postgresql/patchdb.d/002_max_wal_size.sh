#!/usr/bin/env bash

sed -i "s/^\#max_wal_size = .*/max_wal_size = ${POSTGRES_MAX_WAL_SIZE:-16}MB/g" "${PGDATA}"/postgresql.conf
sed -i "s/^\#min_wal_size = .*/min_wal_size = 2MB/g" "${PGDATA}"/postgresql.conf
