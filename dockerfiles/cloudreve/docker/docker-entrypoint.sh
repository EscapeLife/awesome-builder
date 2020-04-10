#!/bin/bash

set -e

WORK_DIR='/opt/cloudreve'
cd ${WORK_DIR}

mkdir -pv /data/logs /data/uploads /data/db
if [ ! -n "${DOCKER_DEBUG}" ]; then
    exec 1>>/data/logs/init.log 2>&1
fi

rm -rf /etc/nginx/sites-enabled/* /etc/supervisor/conf.d/*
cp -rf /docker/nginx/cloudreve.conf /etc/nginx/conf.d/
cp -rf /docker/supervisor/supervisord.conf /etc/supervisor/supervisord.conf
ln -sf /data/uploads /opt/cloudreve/uploads
ln -sf /data/db /opt/cloudreve/cloudreve.db
if [[ ${type_mold} == 'standard' ]]; then
    cp -rf /docker/supervisor/conf.d/standard-cloudreve.conf /etc/supervisor/conf.d/
else
    cp -rf /docker/supervisor/conf.d/minimize-cloudreve.conf /etc/supervisor/conf.d/
fi

supervisord -n -c /etc/supervisor/supervisord.conf
