#!/usr/bin/env bash

EXIT_CODE=1

GOSU_CMD=""
if [[ "$(id -u)" == '0' ]]; then
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

check_backup() {
    if [[ ! -f "${PGDATA}"/../backup/base_database.tar.gz ]]; then
        echo "no base_database.tar.gz found !!!"
        exit $EXIT_CODE
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

start_recovery() {
    for i in $(find "${PGDATA}"/pg_wal -maxdepth 1 -type f -regex ".*?/[0-9A-F]+"); do
        test -f "${PGDATA}"/../backup/wal/$(basename "${i}") || ${GOSU_CMD} zstd -f -q -o "${PGDATA}"/../backup/wal/$(basename "${i}") "${i}"
    done
    rm -rf "${PGDATA}"/*
    tar -C "${PGDATA}" -xzpf "${PGDATA}"/../backup/base_database.tar.gz

    # for old backup, need update postgresql.conf
    /docker-entrypoint-patchdb.d/000_update_config.sh

    ${GOSU_CMD} cp /usr/share/postgresql/10/recovery.conf.sample "${PGDATA}"/recovery.conf
    local recovery_target_time=${RECOVERY_TARGET_TIME:-$(date +'%F %T %Z')}
    {
        echo "recovery_target_time = '${recovery_target_time}'"
        echo "restore_command = 'zstd -d -q -o %p ${PGDATA}/../backup/wal/%f'"
        echo "recovery_target_action = promote"
    } >>"${PGDATA}"/recovery.conf

    if start_pg; then
        # wait for recovery finish
        while test -f "${PGDATA}"/recovery.conf; do
            sleep 5
        done
        stop_pg
        rm -rf "${PGDATA}"/../backup/wal/* "${PGDATA}"/../backup/base_database.tar.gz
        ${GOSU_CMD} tar -C "${PGDATA}" -zcpf "${PGDATA}"/../backup/base_database.tar.gz ./
        echo "recovery finished !!!!"
    else
        echo "recovery failed !!!!"
        exit $EXIT_CODE
    fi
}

check_backup
stop_pg
backup_all_data
start_recovery
