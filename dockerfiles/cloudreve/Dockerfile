FROM ubuntu:18.04

ENV LANG=en_US.UTF-8

WORKDIR /opt/cloudreve

COPY docker /docker
COPY source /opt/cloudreve/

RUN sed -i s/archive.ubuntu.com/mirrors.aliyun.com/g /etc/apt/sources.list && \
    apt update -y && \
    DEBIAN_FRONTEND=noninteractive apt install --no-install-recommends -y gnupg && \
    echo deb http://nginx.org/packages/ubuntu/ bionic nginx > /etc/apt/sources.list.d/nginx.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys ABF5BD827BD9BF62 && \
    apt update -y && \
    DEBIAN_FRONTEND=noninteractive apt install --no-install-recommends -y \
        nginx \
        python3-pip \
        curl \
        wget \
        htop \
        vim.tiny && \
    ln -sf /usr/bin/vim.tiny /usr/bin/vim && \
    mkdir ~/.pip && \
    echo '[global]\nindex-url = https://pypi.douban.com/simple' > ~/.pip/pip.conf && \
    pip3 install setuptools supervisor --upgrade --no-cache-dir && \
    rm -rf /var/lib/apt/lists/* /etc/nginx/sites-enabled/default && \
    mkdir -pv /var/lib/apt/lists/partial && \
    mkdir -pv /etc/supervisor/conf.d

ENTRYPOINT ["/docker/docker-entrypoint.sh"]
