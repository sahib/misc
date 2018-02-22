#!/usr/bin/env python3
# encoding: utf-8

from distutils.core import setup

setup(
    name='image-downloader',
    version='0.0.1',  # Increment according to: http://semver.org
    description='It really just downloads images',
    author='Christopher Pahl',
    author_email='sahib@online.de',
    url='github.com/sahib/misc/challenges/image-downloader',
    packages=['imageloader'],
    # These files here might need to find out the correct PREFIX (i.e.
    # /usr/local instead of /usr):
    data_files=[
        (
            '/usr/share/image-loader/',
            ['misc/example.urls'],
        ), (
            '/usr/lib/systemd/system/',
            ['misc/image-loader.service'],
        ), (
            '/usr/lib/systemd/system/',
            ['misc/image-loader.timer'],
        )
    ]
)
