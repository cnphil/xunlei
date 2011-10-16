xunlei gem
===========

lixian.vip.xunlei.com utility script for Mac OS X users

Summary:
-----------

This is a browser script for lixian.vip.xunlei.com.
It drives Google Chrome to do automation tasks for you, so please
make sure you have Google Chrome installed first.

WARNING:
it stores your USERNAME and PASSWORD for
lixian.vip.xunlei.com as PLAINTEXT at ~/.xunlei/credentials.yml

Install:
-----------

    gem install xunlei

Usage:
-----------

Dump all tasks from web:

    xunlei dump_tasks

Download files

    xunlei download

Download files according to pattern in file names

    xunlei download --only matrix
    xunlei download --except bourne

Pass --help to see more tasks and options

    xunlei --help