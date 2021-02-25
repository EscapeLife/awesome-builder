#!/usr/bin/env bash

GOSU_CMD=""
if [[ "$(id -u)" == '0' ]]; then
    GOSU_CMD="gosu postgres "
fi

start_pg() {
    if ${GOSU_CMD} /usr/lib/postgresql/10/bin/pg_ctl status; then
        echo "postgres service already started, skipping ..."
    else
        echo "starting postgres service ..."
        ${GOSU_CMD} /usr/lib/postgresql/10/bin/pg_ctl start
    fi
}

backup_all_data() {
    if [[ -z "$SKIP_BACKUP" ]]; then
        backup_dir="${PGDATA}"/../backup_$(date +"%Y%m%d%H%M%S")
        echo "starting backup data to ${backup_dir} ..."
        mkdir -p "${backup_dir}"
        if [[ "$(id -u)" == '0' ]]; then
            chown -R postgres "${backup_dir}"
        fi
        cp -rfp "${PGDATA}" "${backup_dir}"
        cp -rfp "${PGDATA}"/../backup "${backup_dir}"
        echo "backup finished..."
    fi
}

start_rebase() {
    echo "remove old files ..."
    rm -rf "${PGDATA}"/../backup/base_database.tar.* "${PGDATA}"/../backup/wal/*
    echo "execute pg_start_backup ..."

    for i in {1..3}; do
        psql -U "${POSTGRES_USER:-postgres}" -d "${POSTGRES_DB:-postgres}" -c "select * from pg_switch_wal();" >/dev/null
    done

    sleep 5

    psql -U "${POSTGRES_USER:-postgres}" -d "${POSTGRES_DB:-postgres}" -c "select pg_start_backup('$(date +"%Y%m%d%H%M%S")');" >/dev/null
    echo "start archive data ..."
    tar -C "${PGDATA}" -cpf - ./ | pv -s "$(du -sb "${PGDATA}" | awk '{print $1}')" | ${GOSU_CMD} zstd -f -q -9 -T0 - -o "${PGDATA}"/../backup/base_database.tar.zst
    echo "execute pg_stop_backup ..."
    psql -U "${POSTGRES_USER:-postgres}" -d "${POSTGRES_DB:-postgres}" -c "select pg_stop_backup();" >/dev/null
    echo "rebase finished !!!!"
}

start_pg
backup_all_data
start_rebase
