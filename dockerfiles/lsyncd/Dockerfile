FROM ubuntu

ENV LANG en_US.UTF-8

COPY entrypoint.sh /entrypoint.sh

RUN apt update && \
    DEBIAN_FRONTEND=noninteractive apt install  -y --no-install-recommends \
        lsyncd \
        locales && \
    chmod +x /entrypoint.sh && \
    rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["/entrypoint.sh"]
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 CMD ["/healthcheck.sh"]
