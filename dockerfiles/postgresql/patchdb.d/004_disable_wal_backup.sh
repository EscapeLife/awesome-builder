#!/usr/bin/env bash

if [[ -z "${DISABLE_WAL_BACKUP}" ]]; then
    sed -i "s/^\#\?archive_mode = .*/archive_mode = on/g" "${PGDATA}"/postgresql.conf
    sed -i "s/^\#\?archive_command = .*/archive_command = '\/usr\/local\/bin\/archive_wal.sh %f %p'/g" "${PGDATA}"/postgresql.conf
else
    sed -i "s/^\#\?archive_mode = .*/archive_mode = off/g" "${PGDATA}"/postgresql.conf
fi
