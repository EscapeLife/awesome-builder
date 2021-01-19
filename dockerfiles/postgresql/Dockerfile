FROM postgres:10

ENV PGDATA=/data/data

COPY init_scripts/* /usr/local/bin/
COPY config_file/* /opt/pgpool/etc/
COPY initdb.d /docker-entrypoint-initdb.d/
COPY docker/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
COPY patchdb.d /docker-entrypoint-patchdb.d/

RUN sed -i s/archive.ubuntu.com/mirrors.aliyun.com/g /etc/apt/sources.list && \
    apt update -y && \
    apt install --no-install-recommends -y \
        build-essential \
        ca-certificates \
        curl \
        gpg \
        htop \
        pv \
        rsync \
        unzip \
        vim.tiny \
        zstd && \
    curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
    echo "deb http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
    apt update && \
    apt install -y \
        postgresql-server-dev-10 \
        postgresql-10-postgis-2.4-scripts && \
    pg_config --pkglibdir && \
    ln -sf /usr/bin/vim.tiny /usr/bin/vim && \
    apt purge --autoremove -y \
        build-essential \
        ca-certificates \
        curl \
        gpg \
        unzip && \
    chmod +x /usr/local/bin/docker-entrypoint.sh && \
    mkdir /data && \
    chmod 777 /data && \
    rm -rf /var/lib/apt/lists/* /tmp/*
