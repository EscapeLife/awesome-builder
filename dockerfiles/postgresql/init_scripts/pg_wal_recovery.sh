#!/usr/bin/env bash

EXIT_CODE=1

GOSU_CMD=""
if [[ "$(id -u)" == '0' ]]; then
    GOSU_CMD="gosu postgres "
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
    if [[ $(find "${PGDATA}"/../backup/ -maxdepth 1 -name "base_database.tar.*" | wc -l) -eq 0 ]]; then
        echo "not found base_database.tar.zst !!!"
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
    echo "starting recovery..."
    for i in $(find "${PGDATA}"/pg_wal -maxdepth 1 -type f -regex ".*?/[0-9A-F]+"); do
        test -f "${PGDATA}/../backup/wal/$(basename "${i}")" ||
            ${GOSU_CMD} zstd -f -q -o "${PGDATA}/../backup/wal/$(basename "${i}")" "${i}"
    done

    echo "starting remove data..."
    rm -rf "${PGDATA:?}"/*

    echo "starting uncompress data..."
    if [[ -f "${PGDATA}"/../backup/base_database.tar.zst ]]; then
        pv "${PGDATA}"/../backup/base_database.tar.zst | tar -C "${PGDATA}" -I "zstd -9 -T0" -xpf -
    fi

    echo "config recovery.conf..."
    # for old backup, need update postgresql.conf
    /docker-entrypoint-patchdb.d/000_update_config.sh

    ${GOSU_CMD} cp /usr/share/postgresql/10/recovery.conf.sample "${PGDATA}"/recovery.conf
    local recovery_target_time=${RECOVERY_TARGET_TIME:-$(date +'%F %T %Z')}
    {
        echo "recovery_target_time = '${recovery_target_time}'"
        echo "restore_command = 'zstd -T0 -d -q -o %p ${PGDATA}/../backup/wal/%f'"
        echo "recovery_target_action = promote"
    } >>"${PGDATA}"/recovery.conf

    if start_pg; then
        # wait for recovery finish
        while test -f "${PGDATA}"/recovery.conf; do
            echo "waiting recovery finish..."
            sleep 5
        done

        echo "recovery finished..."

        SKIP_BACKUP=true /usr/local/bin/pg_wal_rebase.sh

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
