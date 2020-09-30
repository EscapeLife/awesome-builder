# Docker Cropper

> **一个快速迭代的Docker补丁包部署的小程序(裁剪)**

## 1. 安装依赖包

```bash
# requirements
$ pip3 install click sh
```

## 2. 工具使用方式

```bash
# 直接运行后生成postgresql_0.0.2_lite.tar补丁文件
$ python3 ./image_cropper.py -b ./postgresql_0.0.1.tar -l ./postgresql_0.0.2.tar
$ python3 ./image_cropper.py --base-image ./postgresql_0.0.1.tar --latest-image ./postgresql_0.0.2.tar
```
