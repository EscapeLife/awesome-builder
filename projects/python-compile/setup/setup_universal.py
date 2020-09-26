# -*- coding: utf-8 -*-

from setuptools import find_packages, setup

# package meta-data
NAME = 'escape'
VERSION = '0.0.1'
DESCRIPTION = 'This is a test package demo.'

# required packages module
REQUIRED = [
    'grpcio',
    'grpcio-tools'
]

# bdist_wheel
setup(
    name=NAME,
    version=VERSION,
    description=DESCRIPTION,
    packages=find_packages(exclude=["demo"]),
    install_requires=REQUIRED,
    package_dir={'escape': 'escape'},
    package_data={},
    include_package_data=True,
    zip_safe=False,
    python_requires='>=3.6, <4',
    url='https://gitpd.escapelife.site/escape'
)
