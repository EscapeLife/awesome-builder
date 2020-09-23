#!/bin/bash

set -ex

WORK_DIR=$(pwd)

cd "${WORK_DIR}"
rsync -av ../tmp/*.whl escape@pypi.ecapelife.site:/data/pypiserver/packages/escape
rm -rf "${WORK_DIR}"/../tmp
