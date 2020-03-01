#!/bin/bash


#--------------
# setting var
#--------------
find_path=$1
big_file_quota="1024"
big_dir_quota="10240"


#--------------------
# check input argvs
#--------------------
usage() {
    echo "Usage: ./find_big_file.sh dir_path"
    exit -1
}

check_have_dir() {
    if [ ! -d ${find_path} ]; then
        echo "The ${find_path} is no found, please check it first..."
        exit -2
    fi
}


#------------------------
# find big file and dir
#------------------------
find_big_file() {
    echo "[ find big file(unit:M|G|T) ]"
    find ${find_path} -size ${big_file_quota}M -exec ls -lh {} \; 2> /dev/null > find_big_file.log
    file_list=`cat find_big_file.log | awk '{ print $9 }'`

    echo "[ find big dir(unit:M) ]"
    for file in ${file_list}; do
        if [ -n $file ]; then
            dir_size=`${file%/*} | xargs du -sm | awk '{ print $1 }' | sed 's#[B|K|M|G|T]##'`
            if [ ${dir_size} -ge ${big_dir_quota} ]; then
                echo ${file%/*} | xargs du -sh >> find_big_file.log
            fi
        fi
    done

    uniq find_big_file.log > find_big_file.tmp
    mv find_big_file.tmp find_big_file.log
}


#-------
# main
#-------
main() {
    if [ $# -ne 1 ]; then
        usage
    else
        check_have_dir
        find_big_file
    fi

    lines=`cat find_big_file.log | wc -l`
    if [ ${lines} -eq 3 ]; then
        rm find_big_file.log
        echo "OK"
        exit 0
    else
        echo "ERROR"
        exit -3
    fi
}

main $*
