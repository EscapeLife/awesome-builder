#!/usr/bin/env python
# encoding: utf-8

# ========================================================================================================
# [解释下seek()函数的用法]
#   file.seek(off, whence=0)
# 从文件中移动off个操作标记（文件指针），正数往结束方向移动，负数往开始方向移动。
# 如果设定了whence参数，就以whence设定的起始位为准，0代表从头开始，1代表当前位置，2代表文件最末尾位置。
# ========================================================================================================

import time
import subprocess

# ------------------------------
# one way with shell tail -f
# ------------------------------
logfile = 'access.log'
command = 'tail -f '+logfile+'|grep "timeout"'
popen = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
while True:
    line = popen.stdout.readline().strip()
    print(line)

# -------------------------
# twe way with O/I seek
# -------------------------
with open("access.log") as f:
    while True:
        where = f.tell()
        line = f.readline()
        if not line:
            time.sleep(1)
            f.seek(where)
        else:
            print(line,)

# ----------------------
# three way with yield
# ----------------------


def follow(the_file):
    the_file.seek(0, 2)
    while True:
        line = the_file.readline()
        if not line:
            time.sleep(0.1)
            continue
        yield line


if __name__ == '__main__':
    with open("access.log", "r") as logfile:
        log_lines = follow(logfile)
        for line in log_lines:
            print(line,)
