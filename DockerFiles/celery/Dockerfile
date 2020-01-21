FROM debian:jessie

ENV PYTHONIOENCODING UTF-8

# pypy is installed from a package manager because it takes so long to build.
RUN apt-get update && apt-get install -y build-essential \
    libcurl4-openssl-dev \
    libffi-dev \
    tk-dev \
    xz-utils \
    curl \
    lsb-release \
    git \
    libmemcached-dev \
    make \
    liblzma-dev \
    libreadline-dev \
    libbz2-dev \
    llvm \
    libncurses5-dev \
    libssl-dev \
    libsqlite3-dev \
    wget \
    pypy \
    python-openssl \
    libncursesw5-dev \
    zlib1g-dev \
    pkg-config

# update libssl to 1.0.2 from backports to support Python 3.7
RUN echo "deb http://deb.debian.org/debian jessie-backports main" | tee /etc/apt/sources.list.d/jessie-backports.list
RUN apt-get update && apt-get install -y -t jessie-backports libssl-dev

# check for mandatory build arguments
ARG CELERY_USER=developer
RUN : "${CELERY_USER:?CELERY_USER build argument needs to be set and non-empty.}"

# set some args for create user dir
ENV HOME /home/$CELERY_USER
ENV PATH="$HOME/.pyenv/bin:$PATH"

# set tools download dir
ENV PROVISIONING /provisioning

# copy and run setup scripts
WORKDIR $provisioning

# install libcouchbase tool
COPY DOcker/scripts/install-couchbase.sh .
RUN SH install-couchbase.sh

# create linux user is developer
COPY DOcker/scripts/create-linux-user.sh .
RUN SH create-linux-user.sh

# install pyenv tool
# swap to the celery user so packages and celery are not installed as root
USER $CELERY_USER
COPY docker/scripts/install-pyenv.sh .
RUN sh install-pyenv.sh

# install celery lib
WORKDIR $HOME
COPY --chown=1000:1000 requirements $HOME/requirements
COPY --chown=1000:1000 docker/entrypoint /entrypoint
RUN chmod gu+x /entrypoint

# define the local pyenvs
RUN pyenv local python3.6 python3.5 python3.4 python2.7 python3.7

RUN pyenv exec python2.7 -m pip install --upgrade pip setuptools && \
    pyenv exec python3.4 -m pip install --upgrade pip setuptools && \
    pyenv exec python3.5 -m pip install --upgrade pip setuptools && \
    pyenv exec python3.6 -m pip install --upgrade pip setuptools && \
    pyenv exec python3.7 -m pip install --upgrade pip setuptools

# setup one celery environment for basic development use
RUN pyenv exec python3.7 -m pip install \
        -r requirements/default.txt \
        -r requirements/test.txt \
        -r requirements/test-ci-default.txt \
        -r requirements/docs.txt \
        -r requirements/test-integration.txt \
        -r requirements/pkgutils.txt && \
    pyenv exec python3.6 -m pip install \
        -r requirements/default.txt \
        -r requirements/test.txt \
        -r requirements/test-ci-default.txt \
        -r requirements/docs.txt \
        -r requirements/test-integration.txt \
        -r requirements/pkgutils.txt && \
    pyenv exec python3.5 -m pip install \
        -r requirements/default.txt \
        -r requirements/test.txt \
        -r requirements/test-ci-default.txt \
        -r requirements/docs.txt \
        -r requirements/test-integration.txt \
        -r requirements/pkgutils.txt && \
    pyenv exec python3.4 -m pip install \
        -r requirements/default.txt \
        -r requirements/test.txt \
        -r requirements/test-ci-default.txt \
        -r requirements/docs.txt \
        -r requirements/test-integration.txt \
        -r requirements/pkgutils.txt && \
    pyenv exec python2.7 -m pip install \
        -r requirements/default.txt \
        -r requirements/test.txt \
        -r requirements/test-ci-default.txt \
        -r requirements/docs.txt \
        -r requirements/test-integration.txt \
        -r requirements/pkgutils.txt

COPY --chown=1000:1000 . $HOME/celery

WORKDIR $HOME/celery

# Setup the entrypoint, this ensures pyenv is initialized when a container is started
# and that any compiled files from earlier steps or from moutns are removed to avoid
# py.test failing with an ImportMismatchError
ENTRYPOINT ["/entrypoint.sh"]
