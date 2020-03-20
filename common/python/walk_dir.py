#!/usr/bin/env python
# encoding: utf-8

#=======================================================
# 返回一个三元组tupple(dirpath, dirnames, filenames)
# 根路径，根路径下的子目录列表，根路径下的所有文件列表
#=======================================================

import os
import sys

def check_user():
    if not os.geteuid()==0:
        sys.exit(0)


def find_file(path):
    file_list = []
    for root, dirs, files in os.walk(path):
        for file in files:
            file_list.append(file)
        for dir in dirs:
            new_path = os.path.join(root, dir)
            find_file(new_path)
    print file_list


if __name__ == '__main__':
    check_user
    find_file("/home/escape")
