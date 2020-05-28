FROM ubuntu:18.04

WORKDIR /opt/subsonic

ENV LANG=en_US.UTF-8

COPY . /opt/subsonic/

RUN sed -i s/archive.ubuntu.com/mirrors.aliyun.com/g /etc/apt/sources.list && \
    apt update -y && \
    DEBIAN_FRONTEND=noninteractive apt install --no-install-recommends -y \
        wget \
        htop \
        tzdata \
        locales \
        openjdk-8-jre && \
    locale-gen en_US.UTF-8 && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    dpkg -i /opt/subsonic/subsonic-6.1.6.deb && \
    rm -rf /var/lib/apt/lists/* /tmp/* && \
    mkdir -pv /var/lib/apt/lists/partial

ENTRYPOINT ["/opt/subsonic/docker/docker-entrypoint.sh"]
