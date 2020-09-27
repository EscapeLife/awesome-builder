ppFROM postgres:10

ENV PGDATA=/data/data

COPY init_scripts/* /usr/local/bin/
COPY config_file/* /opt/pgpool/etc/
COPY initdb.d /docker-entrypoint-initdb.d/
COPY docker/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
COPY patchdb.d /docker-entrypoint-patchdb.d/

RUN sed -i s/archive.ubuntu.com/mirrors.aliyun.com/g /etc/apt/sources.list && \
    apt update -y && \
    apt install --no-install-recommends -y \
        ca-certificates \
        build-essential \
        vim.tiny \
        gpg \
        zstd \
        wget \
        curl \
        htop && \
    curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
    echo "deb http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
    apt update && \
    apt install -y \
        postgresql-server-dev-10 \
        postgresql-10-postgis-2.4-scripts && \
    pg_config --pkglibdir && \
    ln -sf /usr/bin/vim.tiny /usr/bin/vim && \
    mkdir -pv /opt/pgpool /var/run/pgpool /var/log/pgpool && \
    wget http://www.pgpool.net/download.php?f=pgpool-II-4.1.1.tar.gz -O /tmp/pgpool-II-4.1.1.tar.gz && \
    tar -zxf /tmp/pgpool-II-4.1.1.tar.gz -C /tmp && \
    cd /tmp/pgpool-II-4.1.1 && ./configure --prefix=/opt/pgpool && make && make install && \
    apt purge --autoremove -y \
        curl \
        wget \
        ca-certificates \
        build-essential && \
    chown -R postgres:postgres /opt/pgpool /var/run/pgpool /var/log/pgpool /usr/local/bin/failover_command.sh /usr/local/bin/attach_node.sh && \
    chmod +x /usr/local/bin/docker-entrypoint.sh && \
    mkdir /data && \
    chmod 777 /data && \
    rm -rf /var/lib/apt/lists/* /tmp/*
