# Xiqu Login Fen

> **签到打卡领积分**

## 1. 安装依赖包

```bash
# requirements
$ pip3 install --no-cache-dir -r requirements.txt
```

## 2. 工具使用方式

```bash
# command line
$ python3 xiqu_99.py --help
```

## 3. 镜像使用方式

```bash
# build
$ docker build -t xiqu .

# bg
$ docker run -d --name xiqu xiqu

# run
$ docker run -it --rm --name xiqu xiqu
```

```bash
# save
$ docker save xiqu:latest -o xiqu_latest.tar

# load
$ docker load -i xiqu_latest.tar
```

## 4. 使用公共镜像

```bash
# bg
$ docker run -d --name xiqu \
    -e XIQU_99_USERNAME='' -e XIQU_99_PASSWORD='' \
    escape/xiqu:latest

# run
$ docker run -it --rm --name xiqu \
    -e XIQU_99_USERNAME='' -e XIQU_99_PASSWORD='' \
    escape/xiqu:latest
```
