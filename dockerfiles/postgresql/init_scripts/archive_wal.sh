#!/usr/bin/env bash

EXIT_CODE=1

if [[ -d "$PGDATA/../backup/wal" ]]; then
    zstd -f -q -o "$PGDATA/../backup/wal/${1}" "${2}"
    # restore_command set 'zstd -d -q -o %p /wal_backup_path/%f'
    EXIT_CODE=$?
fi

exit ${EXIT_CODE}
