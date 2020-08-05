FROM pytorch/pytorch

WORKDIR /opt/easyocr

ARG service_home="/home/easyocr"
ARG language_models="['ch_sim','en']"
ARG enable_gpu=False

RUN sed -i s/archive.ubuntu.com/mirrors.aliyun.com/g /etc/apt/sources.list && \
    apt update -y && \
    apt install --no-install-recommends -y \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    git && \
    apt-get autoremove && apt-get clean -y && \
    rm -rf /var/lib/apt/list/*

RUN mkdir "$service_home" && \
    git clone "https://github.com/JaidedAI/EasyOCR.git" "$service_home" && \
    cd "$service_home" && \
    git remote add upstream "https://github.com/JaidedAI/EasyOCR.git" && \
    git pull upstream master

RUN cd "$service_home" && \
    python setup.py build_ext --inplace -j 4 && \
    python -m pip install -e .

RUN python -c "import easyocr; reader = easyocr.Reader(${language_models}, gpu=${enable_gpu})"
