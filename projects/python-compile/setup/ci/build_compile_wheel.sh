#!/bin/bash

set -ex

WORK_DIR=$(pwd)
mkdir -pv "${WORK_DIR}"/tmp

clean_work_dir() {
    rm -rf "${WORK_DIR}"/tmp
    rm -rf "${WORK_DIR}"/build "${WORK_DIR}"/dist "${WORK_DIR}"/escape.egg-info
    git clean -fdx
}

update_version() {
    sed -i "s#VERSION = .*#VERSION = \'0.0.${ESCAPE_PIPELINE_COUNTER:-dev}\'#g" "${WORK_DIR}"/setup.py
}

build() {
    cd "${WORK_DIR}"
    python3 setup.py build_ext --inplace --force
    python3 setup.py bdist_wheel
    rsync -av dist/*.whl ../tmp/
    rm -rf "${WORK_DIR}"/build "${WORK_DIR}"/dist "${WORK_DIR}"/escape.egg-info
    cd ..
}

clean_work_dir
update_version
build
