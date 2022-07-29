#!/usr/bin/env python
# encoding: utf-8

# ======================================================================
# 1、OrderedDict
# 这个功能是可以生成有序字典，大家都知道在python中字典是无序的
# 当然你也可以根据kye来排序，但用OrderedDict就可以直接生成有序字典
# 有序字典的顺序只跟你添加的顺序有关
#
# 2、namedtuple
# 功能是可以给元组的索引起个名字，一般我们访问元组，只能用索引去访问
# 但如果给索引定义了名字，你就可以用定义的这个名字去访问了
#
# 3、glob
# 它主要方法就是glob，它返回所有匹配的文件列表
# ======================================================================

import os
import re
import glob
from collections import OrderedDict
from collections import namedtuple


def cup_info():
    n_procs = 0
    cpuinfo = OrderedDict()
    proc_info = OrderedDict()
    with open('/proc/cpuinfo', 'r') as f:
        for line in f:
            if not line.strip():
                cpuinfo['proc%s' % n_procs] = proc_info
                n_procs += 1
                proc_info = OrderedDict()
            else:
                if len(line.split(':')) == 2:
                    proc_info[line.split(':')[0].strip()] = line.split(':')[1].strip()
                else:
                    proc_info[line.split(':')[0].strip()] = ''
    return cpuinfo


def mem_info():
    meminfo = OrderedDict()
    with open('/proc/meminfo', 'r') as f:
        for line in f:
            meminfo[line.split(':')[0].strip()] = line.split(':')[1].strip()
    return meminfo


def net_devs():
    with open('/proc/net/dev', 'r') as f:
        net_dump = f.readlines()

    device_data = {}
    data = namedtuple('data', ['rx', 'tx'])
    for line in net_dump[2:]:
        line = line.split(':')
        if line[0].strip() != 'lo':
            device_data[line[0].strip()] = data(float(line[1].split()[0])/(1024.0*1024.0),
                                                float(line[1].split()[8])/(1024.0*1024.0))
    return device_data


def process_list():
    pids = []
    for subdir in os.listdir('/proc'):
        if subdir.isdigit():
            pids.append(subdir)
    return pids


def size(device):
    nr_sectors = open(device+'/size').read().rstrip('\n')
    sect_size = open(device+'/queue/hw_sector_size').read().rstrip('\n')
    return (float(nr_sectors)*float(sect_size))/(1024.0*1024.0*1024.0)


def detect_devs(dev_pattern):
    for device in glob.glob('/sys/block/*'):
        for pattern in dev_pattern:
            if re.compile(pattern).match(os.path.basename(device)):
                print('Device:: {0}GiB'.format(device, size(device)))


if __name__ == '__main__':
    cpu_info = cup_info()
    for processor in cpu_info.keys():
        print(cpu_info[processor]['model name'])

    mem_info = mem_info()
    print('Total memory: {0}'.format(mem_info['MemTotal']))
    print('Free memory: {0}'.format(mem_info['MemFree']))

    net_devs = net_devs()
    for dev in net_devs.keys():
        print('{0}: {1}MiB {2}MiB'.format(dev, net_devs[dev].rx, net_devs[dev].tx))

    pids = process_list()
    print("Total number of running processes:: {0}".format(len(pids)))

    dev_pattern = ['sd.*', 'xv*']
    detect_devs(dev_pattern)
