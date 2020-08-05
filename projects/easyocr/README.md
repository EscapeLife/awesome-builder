# EasyOCR

> **Ready-to-use OCR with 40+ languages supported including Chinese, Japanese, Korean and Thai.**

![EasyOCR](../../images/dockerfiles/linux-easyocr-tool.png)

---

## 1. build docker image

```bash
# build easyocr image
$ docker build --squash --no-cache --tag=easyocr:latest .
```

## 2. run docker image

```bash
# run easyocr container
$ docker run --restart=always --name=easyocr -d -p 8000:8000 \
    -v "./model:~/.EasyOCR/model" \
    easyocr:latest
```
