FROM ubuntu:18.04

ENV LANG=en_US.UTF-8

WORKDIR /opt/cyc

SHELL ["/bin/bash", "-c"]

RUN set -o pipefail && \
    sed -i 's/archive.ubuntu/mirrors.aliyun/g' /etc/apt/sources.list && \
    apt update && \
    DEBIAN_FRONTEND=noninteractive apt install --no-install-recommends -y \
        python3-dev \
        python3-pip \
        ca-certificates \
        build-essential \
        curl \
        wget \
        htop \
        locales && \
    locale-gen en_US.UTF-8 && \
    mkdir ~/.pip /opt/cyc/cache && \
    echo -e '[global]\nindex-url = https://pypi.douban.com/simple' > /etc/pip.conf && \
    pip3 install --upgrade --pre cython sanic --no-cache && \
    rm -rf ~/.cache /tmp/* /var/log/* /var/lib/apt/lists/*

ADD run_server.py /opt/cyc/

ENTRYPOINT ["python3", "run_server.py"]
