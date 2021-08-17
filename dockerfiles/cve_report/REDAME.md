# Tencent Security Report

> **提供最实时的威胁情报**

## 1. 安装依赖包

```bash
# requirements
$ pip3 install --no-cache-dir -r requirements.txt
```

## 2. 工具使用方式

```bash
# command line
$ python3 security_report_cmd.py --help
Usage: security_report_cmd.py [OPTIONS]
Options:
  --init     initialize the sqlite database
  --check    check the most real-time threat intelligence
  --delete   delete the first two rows in the database table
  --display  displays the latest vulnerability list information
  --help     Show this message and exit
```

## 3. 镜像使用方式

```bash
# build
$ docker build -t cve_report .

# run bg
$ docker run -d --name cve_report cve_report

# run once
$ docker run -it --rm --name cve_report cve_report
```

```bash
# save
$ docker save cve_report:latest -o cve_report_latest.tar

# load
$ docker load -i cve_report_latest.tar
```
