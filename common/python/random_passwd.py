#!/usr/bin/env python
# encoding: utf-8

import string
import random


def get_passwd():
    passwd = []
    for i in range(4):
        passwd.append(random.choice(string.lowercase))
        passwd.append(random.choice(string.uppercase))
        passwd.append(random.choice(string.digits))
        passwd.append(random.choice(["%", ".", "@", "!", "&", "#"]))

    # 将列表元素打乱重新排列
    random.shuffle(passwd)
    passwd = ''.join()
    return passwd


if __name__ == '__main__':
    with open('output_passwd.txt', 'rw') as output_passwd_file:
        with open('user.txt', 'rw') as user_file:
            for username in user_file:
                output_passwd_file.write(username.strip() + '=' + get_passwd() + '\n')
