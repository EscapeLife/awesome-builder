#!/bin/bash

# -----------------------------------------------------------------------
# Init Text Print Colors
# -----------------------------------------------------------------------
# reset color
ColorReset='\033[0m'  # reset

# regular colors
Black='\033[0;30m'   # black
Red='\033[0;31m'     # red
Green='\033[0;32m'   # green
Yellow='\033[0;33m'  # yellow
Blue='\033[0;34m'    # blue
Purple='\033[0;35m'  # purple
Cyan='\033[0;36m'    # cyan
White='\033[0;37m'   # white


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

echo_info() {
    if [ ${_arg_quiet} == "on" ]; then
        echo -e "$@" &> /dev/null
    else
        echo -e "$@"
    fi
}

begins_with_short_option() {
    local first_option all_short_options
    all_short_options='xptsqh'
    first_option="${1:0:1}"
    test "$all_short_options" = "${all_short_options/$first_option/}" && return 1 || return 0
}


# -----------------------------------------------------------------------
# The Defaults Initialization Optionals
# -----------------------------------------------------------------------
_arg_script_filename="${0##*/}"
_arg_host_and_port=""
_arg_host=""
_arg_port=""
_arg_timeout="15"
_arg_strict="off"
_arg_quiet="off"
_arg_cmd_signal="off"
_arg_wait_for_ready_cmd=""

print_help() {
    printf '%s\n' "Focus on testing and waiting for TCP host and port availability."
    printf 'Usage: %s IP:PORT [-t|--timeout <arg>] [--strict|--no-strict] [--quiet|--no-quiet] [-- <arg>] [-h|--help]\n' "${_arg_script_filename}"
    printf '\t%s\n' "IP: Host or IP under test (no default)"
    printf '\t%s\n' "PORT: TCP port under test (no default)"
    printf '\t%s\n' "-t: Timeout in seconds and zero for no timeout (default 15s)"
    printf '\t%s\n' "--strict: Only execute subcommand if the test succeeds (default off)"
    printf '\t%s\n' "--quiet: Don not output any status messages (default off)"
    printf '\t%s\n' "-- command: Execute command with args after the test finishes (no default)"
    printf '\t%s\n' "-h/--help: Prints help"
}

parse_commandline() {
    while test $# -gt 0; do
        _key="$1"
        case "$_key" in
            *:* )
                _arg_host_and_port=(${_key//:/ })
                _arg_host=${_arg_host_and_port[0]}
                _arg_port=${_arg_host_and_port[1]}
                ;;
            -t)
                test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
                _arg_timeout="$2"
                shift
                ;;
            --)
                shift
                _arg_cmd_signal="on"
                _arg_wait_for_ready_cmd=("$@")
                break
                ;;
            --strict|--no-strict)
                _arg_strict="on"
                test "${1:0:5}" = "--no-" && _arg_strict="off"
                ;;
            --quiet|--no-quiet)
                _arg_quiet="on"
                test "${1:0:5}" = "--no-" && _arg_quiet="off"
                ;;
            -h|--help)
                print_help
                exit 0
                ;;
            *)
                _PRINT_HELP=yes die "FATAL ERROR: Got an unexpected argument '$1'" 1
                ;;
        esac
        shift
    done
}

if [ $# -eq 0 ]; then
    print_help && exit 0
else
    parse_commandline "$@"
fi


# -----------------------------------------------------------------------
# Test The Parameters Are In Compliance
# -----------------------------------------------------------------------
# check host and ip not noe
if [ -z ${_arg_host} ] || [ -z ${_arg_port} ]; then
    echo -e "${Red}[WARNING]${ColorReset} ${Green}the input ip or host is none, please check!${ColorReset} => ${Yellow}IP:<${_arg_host}> HOST:<${_arg_port}> ${ColorReset}"
    exit 1
fi

# check command not none
if [ "${_arg_cmd_signal}" == "on" ]; then
    if [[ -z ${_arg_wait_for_ready_cmd} ]]; then
        echo -e "${Red}[WARNING]${ColorReset} ${Green}the input command is none, please check!${ColorReset}"
        exit 1
    fi
fi

# check nc command installed
nc_path=$(type -p nc)
if [ $? -eq 0 ]; then
    nc_path=$(realpath ${nc_path} 2>/dev/null || readlink -f ${nc_path})
    if [ ${nc_path} == "/usr/bin/ncat" ]; then
        echo -e "${Red}[WARNING]${ColorReset} ${Green}the ncat tool is not currently supported by this script, please check!${ColorReset}"
        exit 2
    fi
else
    echo -e "${Red}[WARNING]${ColorReset} ${Green}the nc command is not found, please check!${ColorReset}"
    exit 2
fi

# check input timeout number is a positive integer
check_timeout_arg() {
    if [ ${_arg_timeout} -lt 0 ]; then
        echo -e "${Red}[WARNING]${ColorReset} ${Green}the timeout wait time is worry, please check!${ColorReset}"
        exit 3
    else
        echo_info "${_arg_script_filename}: waiting ${_arg_timeout} seconds for ${_arg_host}:${_arg_port}"
    fi
}


# -----------------------------------------------------------------------
# Run Waiting For Connect Server
# -----------------------------------------------------------------------
wait_for_connect() {
    connect_start_time=$(date +%s)
    while true; do
        ${nc_path} -w 1 -z ${_arg_host} ${_arg_port} &> /dev/null
        connet_result="$?"
        if [[ ${connet_result} -eq 0 ]]; then
            connect_end_time=$(date +%s)
            echo_info "${_arg_script_filename}: ${_arg_host}:${_arg_port} is available after $((connect_end_time - connect_start_time)) seconds ..."
            break
        else
            connect_end_time=$(date +%s)
            run_command_time=$((connect_end_time - connect_start_time))
            if [ ${run_command_time} -gt ${_arg_timeout} ]; then
                echo_info "${_arg_script_filename}: timeout occurred after waiting ${_arg_timeout} seconds for ${_arg_host}:${_arg_port} ..."
                break
            fi
        fi
    done
    return ${connet_result}
}


# -----------------------------------------------------------------------
# The Main Logic
# -----------------------------------------------------------------------
main() {
    check_timeout_arg
    wait_for_connect
    connet_result="$?"

    if [[ -n ${_arg_wait_for_ready_cmd} ]]; then
        if [[ ${connet_result} -ne 0 && ${_arg_strict} == "on" ]]; then
            echo_info "${_arg_script_filename}: strict mode, refusing to execute subprocess ..."
            exit ${connet_result}
        fi
        exec "${_arg_wait_for_ready_cmd[@]}"
    else
        exit ${connet_result}
    fi
}

main
