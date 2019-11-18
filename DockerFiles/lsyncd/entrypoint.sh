#!/usr/bin/env bash

set -e

# -----------------------------------------------------------------------
# Parse Commandline Function
# -----------------------------------------------------------------------
die() {
    local _ret=$2
    test -n "$_ret" || _ret=1
    test "$_PRINT_HELP" = yes && print_help >&2
    echo "$1" >&2
    exit ${_ret}
}

begins_with_short_option() {
    local first_option all_short_options
    all_short_options='h'
    first_option="${1:0:1}"
    test "$all_short_options" = "${all_short_options/$first_option/}" && return 1 || return 0
}


# -----------------------------------------------------------------------
# The Defaults Initialization Optionals
# -----------------------------------------------------------------------
_arg_slave="off"
_arg_port=873
_arg_ip="rsyncd"
_arg_delete="false"
_arg_password="password"
_arg_dest="/"
_extra_rsync_args=""
_extra_exclude_args=""
_arg_delay=15
_rsyncd_log_path="/dev/null"
_lsyncd_log_level="scarce"

parse_commandline ()
{
    while test $# -gt 0
    do
        _key="$1"
        case "$_key" in
            --no-slave|--slave)
                _arg_slave="on"
                test "${1:0:5}" = "--no-" && _arg_slave="off"
                ;;
            --ip)
                test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
                _arg_ip="$2"
                shift
                ;;
            --ip=*)
                _arg_ip="${_key##--ip=}"
                ;;
            --port)
                test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
                _arg_port="$2"
                shift
                ;;
            --port=*)
                _arg_port="${_key##--port=}"
                ;;
            --delete)
                _arg_delete="true"
                ;;
            --debug)
                _rsyncd_log_path="/dev/stdout"
                _lsyncd_log_level="Exec"
            --password)
                test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
                _arg_password="$2"
                shift
                ;;
            --password=*)
                _arg_password="${_key##--password=}"
                ;;
            --delay)
                test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
                _arg_delay="$2"
                shift
                ;;
            --delay=*)
                _arg_delay="${_key##--delay=}"
                ;;
            --dest)
                test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
                _arg_dest="$2"
                shift
                ;;
            --dest=*)
                _arg_dest="${_key##--dest=}"
                ;;
            --exclude)
                test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
                _extra_exclude_args=${_extra_exclude_args}"\"$2\", "
                shift
                ;;
            --exclude=*)
                _extra_exclude_args=${_extra_exclude_args}"\"${_key##--exclude=}\", "
                ;;
            --limit)
                test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
                _extra_rsync_args=${_extra_rsync_args}", \"--bwlimit=$2\""
                shift
                ;;
            --limit=*)
                _extra_rsync_args=${_extra_rsync_args}", \"--bwlimit=${_key##--limit=}\""
                ;;
            *)
                _PRINT_HELP=yes die "FATAL ERROR: Got an unexpected argument '$1'" 1
                ;;
        esac
        shift
    done
}

parse_commandline "$@"


# -----------------------------------------------------------------------
# Run Build Rsyncd or Lsyncd Server
# -----------------------------------------------------------------------
gen_rsyncd_config() {
    mkdir -p /etc/rsyncd/
    cat > /etc/rsyncd/rsyncd.conf << EOL
uid = root
gid = root
use chroot = yes
max connections = 32
log file = ${_rsyncd_log_path}
strict modes = yes
syslog facility = local5
port = 873
[data]
path = /data/
comment = paoding rsyncd service
ignore errors
read only = no
list = yes
auth users = rsync
secrets file = /etc/rsyncd/rsyncd.pwd
EOL

    cat > /etc/rsyncd/rsyncd.pwd << EOL
rsync:${_arg_password}
EOL

    chmod 600 /etc/rsyncd/rsyncd.pwd
}

gen_lsyncd_config() {
    mkdir -p /etc/lsyncd/
    if [[ ${_extra_exclude_args} != "" ]]; then
        _extra_exclude_args="exclude = {"${_extra_exclude_args}"},"
    fi

    cat >/etc/lsyncd/lsyncd.conf <<EOL
settings {
    insist = true,
    logfile = "/dev/stdout",
    nodaemon = true,
    statusFile = "/run/lsyncd.status",
    inotifyMode = "CloseWrite",
    maxProcesses = 16,
    }

sync {
    default.rsync,
    source    = "/data",
    target    = "rsync@${_arg_ip}::data${_arg_dest}",
    delete = ${_arg_delete},
    ${_extra_exclude_args}
    delay = ${_arg_delay},
    rsync     = {
        binary = "/usr/bin/rsync",
        archive = true,
        compress = true,
        password_file = "/etc/lsyncd/rsync.pwd",
        owner = true,
        perms = true,
        xattrs = true,
        _extra    = {"--port=${_arg_port}" ${_extra_rsync_args}
                    }
        }
    }
EOL

    cat > /etc/lsyncd/rsync.pwd <<EOL
${_arg_password}
EOL

    chmod 600 etc/lsyncd/rsync.pwd
}

run_rsyncd() {
    gen_rsyncd_config
    /usr/bin/rsync --daemon  --no-detach --config=/etc/rsyncd/rsyncd.conf
}

run_lsyncd() {
    gen_lsyncd_config
    lsyncd -log Exec /etc/lsyncd/lsyncd.conf
}

main() {
    mkdir -p /data
    if [[ "${_arg_slave}" == "off" ]]; then
        run_rsyncd
    else
        run_lsyncd
    fi
}


# -----------------------------------------------------------------------
# The Main Function
# -----------------------------------------------------------------------
main
