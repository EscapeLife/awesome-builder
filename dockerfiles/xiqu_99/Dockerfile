FROM ubuntu:18.04

ENV LANG=en_US.UTF-8

WORKDIR /opt/xiqu

COPY . /opt/xiqu/

SHELL ["/bin/bash", "-c"]

RUN set -o pipefail && \
    sed -i s/archive.ubuntu.com/mirrors.aliyun.com/g /etc/apt/sources.list && \
    apt update -y && \
    DEBIAN_FRONTEND=noninteractive apt install --no-install-recommends -y \
        python3.6-dev \
        python3-pip \
        python3-distutils \
        vim.tiny \
        tzdata \
        locales \
        gconf-service \
        libasound2 \
        libatk1.0-0 \
        libatk-bridge2.0-0 \
        libc6 \
        libcairo2 \
        libcups2 \
        libdbus-1-3 \
        libexpat1 \
        libfontconfig1 \
        libgcc1 \
        libgconf-2-4 \
        libgdk-pixbuf2.0-0 \
        libglib2.0-0 \
        libgtk-3-0 \
        libnspr4 \
        libpango-1.0-0 \
        libpangocairo-1.0-0 \
        libstdc++6 \
        libx11-6 \
        libx11-xcb1 \
        libxcb1 \
        libxcomposite1 \
        libxcursor1 \
        libxdamage1 \
        libxext6 \
        libxfixes3 \
        libxi6 \
        libxrandr2 \
        libxrender1 \
        libxss1 \
        libxtst6 \
        ca-certificates \
        fonts-liberation \
        libappindicator1 \
        libnss3 \
        lsb-release \
        xdg-utils \
        wget \
        libcairo-gobject2 \
        libxinerama1 \
        libgtk2.0-0 \
        libpangoft2-1.0-0 \
        libthai0 \
        libpixman-1-0 libxcb-render0 \
        libharfbuzz0b \
        libdatrie1 \
        libgraphite2-3 \
        libgbm1 \
        cron \
        rsyslog \
        libgl1-mesa-glx \
        chromium-chromedriver && \
    ln -sf /usr/bin/vim.tiny /usr/bin/vim && \
    ln -sf /usr/bin/python3.6 /usr/bin/python3 && \
    ln -sf /usr/bin/python3.6-config /usr/bin/python3-config && \
    locale-gen en_US.UTF-8 && \
    export LANG="en_US.UTF-8" && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo 'Asia/Shanghai' >/etc/timezone && \
    echo -e '[global]\nindex-url = https://pypi.douban.com/simple' > /etc/pip.conf && \
    pip3 install pip setuptools --upgrade &&\
    pip3 install -r /opt/xiqu/requirements.txt && \
    sed -i s#storage.googleapis.com#npm.taobao.org/mirrors#g /usr/local/lib/python3.6/dist-packages/pyppeteer/chromium_downloader.py && \
    mkdir -pv /root/.EasyOCR/model && mv english_g2.pth /root/.EasyOCR/model && \
    service rsyslog start && \
    mv ./xiqu_cron /etc/cron.d/ && \
    crontab /etc/cron.d/xiqu_cron && \
    touch /opt/xiqu/xiqu_99.log

CMD cron && tail -f /opt/xiqu/xiqu_99.log
