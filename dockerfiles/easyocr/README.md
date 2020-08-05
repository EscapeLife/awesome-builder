# EasyOCR

> **Ready-to-use OCR with 40+ languages supported including Chinese, Japanese, Korean and Thai.**

![EasyOCR](../../images/dockerfiles/linux-easyocr-tool.jpg)

## 1. create local dir

```bash
# frontend
$ mkdir -p /srv/goaccess/{data,html}
```

## 2. clone goaccess project

```bash
# github clone
$ git clone https://github.com/allinurl/goaccess.git goaccess && cd $_
```

## 3. build docker image

```bash
# build goaccess image
$ docker build --squash --no-cache --tag=goaccess:latest .
```

## 4. run docker image

```bash
# run goaccess container
$ docker run --restart=always --name=goaccess -d -p 7890:7890 \
    -v "/srv/goaccess/data:/srv/data" \
    -v "/srv/goaccess/html:/srv/report" \
    -v "/var/log/apache2:/srv/logs" \
    goaccess:latest
```
