#!/bin/bash

# -----------------------------------------------------------------------
# Init Text Print Colors
# -----------------------------------------------------------------------
# reset color
ColorReset='\033[0m' # reset

# regular colors
Black='\033[0;30m'  # black
Red='\033[0;31m'    # red
Green='\033[0;32m'  # green
Yellow='\033[0;33m' # yellow
Blue='\033[0;34m'   # blue
Purple='\033[0;35m' # purple
Cyan='\033[0;36m'   # cyan
White='\033[0;37m'  # white

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

is_command() {
    command -v "$1" >/dev/null 2>&1
}

# -----------------------------------------------------------------------
# The Defaults Initialization Optionals
# -----------------------------------------------------------------------
_arg_src=
_arg_image=

print_help() {
    printf '%s\n' "A plugless docker mirroring installation package generator"
    printf 'Usage: %s [--src <arg>] [--image <arg>] [-h|--help]\n' "$0"
    printf '\t%s\n' "--src: ready to be packed archive tar file (request)"
    printf '\t%s\n' "--image: show image name and version (request )"
    printf '\t%s\n' "-h,--help: Prints help"
}

parse_commandline() {
    while test $# -gt 0; do
        _key="$1"
        case "$_key" in
        --src)
            test $# -lt 2 && die "[ERROR]: Missing value for the optional argument '$_key'." 1
            _arg_src="$2"
            shift
            ;;
        --src=*)
            _arg_src="${_key##--src=}"
            ;;
        --image)
            test $# -lt 2 && die "[ERROR]: Missing value for the optional argument '$_key'." 1
            _arg_image="$2"
            shift
            ;;
        --image=*)
            _arg_image="${_key##--image=}"
            ;;
        -h | --help)
            print_help
            exit 0
            ;;
        -h*)
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
    print_help
    exit 0
else
    parse_commandline "$@"
fi

# -----------------------------------------------------------------------
# Create Self-Extractable Tar Package
# -----------------------------------------------------------------------
if [ -z ${_arg_src} ] || [ -z ${_arg_image} ]; then
    print_help
    exit 0
elif [ ! -f ${_arg_src} ]; then
    echo "[ERROR]: The ${_arg_src} is not file, please check!"
    exit 0
fi

if ! is_command makeself; then
    echo "[ERROR]: The makeself command dose not exist, please check!"
    exit 1
fi

tar_name="$(basename ${_arg_src})"
dir_name="$(dirname ${_arg_src})"
file_name="${tar_name%.*}"
makeself_name="${file_name}.run"
archive_dir="${file_name}_packages"
install_name="install.sh"
commit_message="${file_name} installer for program"

rmdir /tmp/${archive_dir} >/dev/null 2>&1
mkdir -vp /tmp/${archive_dir}
trap "rm -rf /tmp/${archive_dir}" EXIT
cp ${_arg_src} /tmp/${archive_dir}

# check image name and version
file_product="${file_name%_*}"
file_version="${file_name##*_}"
input_product="${_arg_image%:*}"
input_version="${_arg_image##*:}"
if [ ${file_product} != ${input_product} ] || [ ${file_version} != ${input_version} ]; then
    echo -e "[INFO] the package path name =>${Red} ${file_name} ${ColorReset}"
    echo -e "[INFO] the input images name =>${Red} ${_arg_image} ${ColorReset}"
    echo "[ERROR]: Please check the package path name does not match the input images name."
    exit 0
fi

# create install.sh for self-extractable
cat >/tmp/${archive_dir}/${install_name} <<EOF
#!/bin/bash

which docker > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "[ERROR]: The docker command dose not exist."
    exit 1
fi

echo "[INFO]: Load docker images now..."
for image in ./*.tar; do
    if docker load -i \${image}; then
        echo "[INFO]: The docker images load successful."
    else
        echo "[ERROR]: The docker images load failure."
        exit 1
    fi
done
EOF

# create makeself file
# makeself --gzip --notemp --follow ./packages ./packages.run "SFX installer for program" ./install.sh
chmod 755 /tmp/${archive_dir}/${install_name}
makeself --gzip --follow --nooverwrite /tmp/${archive_dir} ${dir_name}/${makeself_name} "${commit_message}" ./${install_name}

# -----------------------------------------------------------------------
# Generation Download Links And Package Information
# -----------------------------------------------------------------------
if ! is_command md5_sum; then
    md5_sum=$(md5sum ${dir_name}/${makeself_name} 2>/dev/null)
elif ! is_command md5; then
    md5_sum=$(md5 -q ${dir_name}/${makeself_name} 2>/dev/null)
else
    echo "[ERROR]: The md5sum and md5 command dose not exist."
    exit 1
fi

printf '\n%s\n' "============================================"
printf '%3s\t%s\t%s\n' "1" "MD5" "${md5_sum}"
printf '%3s\t%s\t%s' "2" "EXP" "${expiration_time}"
printf '\n%s\n' "============================================"
