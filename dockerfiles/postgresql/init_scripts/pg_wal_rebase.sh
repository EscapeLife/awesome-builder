#!/usr/bin/env bash

EXIT_CODE=1

GOSU_CMD=""
if [[ "$(id -u)" = '0' ]]; then
    GOSU_CMD="gosu postgres "
fi

if [[ -n "$POSTGRES_ROLE" ]]; then
    echo "master-slave mode not support!!!"
    exit ${EXIT_CODE}
fi

stop_pg() {
    echo "stopping postgres service..."
    ${GOSU_CMD} /usr/lib/postgresql/10/bin/pg_ctl stop
}

start_pg() {
    echo "starting postgres service..."
    ${GOSU_CMD} /usr/lib/postgresql/10/bin/pg_ctl start
}

backup_all_data() {
    if [[ -z "$SKIP_BACKUP" ]]; then
        backup_dir="${PGDATA}"/../backup_$(date +"%Y%m%d%H%M%S")
        echo "starting backup data to ${backup_dir} ..."
        mkdir -p "${backup_dir}"
        if [[ "$(id -u)" = '0' ]]; then
            chown -R postgres "${backup_dir}"
        fi
        cp -rfp "${PGDATA}" "${backup_dir}"
        cp -rfp "${PGDATA}"/../backup "${backup_dir}"
        echo "backup finished..."
    fi
}

start_rebase() {
    rm -rf "${PGDATA}"/../backup/base_database.tar.gz "${PGDATA}"/../backup/wal/*
    ${GOSU_CMD} tar -C "${PGDATA}" -czpf "${PGDATA}"/../backup/base_database.tar.gz ./
    echo "rebase finished !!!!"
}

stop_pg
backup_all_data
start_rebase
start_pg
