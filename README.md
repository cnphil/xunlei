xunlei gem
===========

lixian.vip.xunlei.com utility script for Mac OS X users

Summary:
-----------

This is a browser script for lixian.vip.xunlei.com.
It drives Google Chrome with [chromedriver](http://code.google.com/p/selenium/wiki/ChromeDriver) to do automation tasks for you,
so please make sure you have Google Chrome installed first.

It can automatically dump task file names and urls as well as browser cookies,
so that it can delegate to wget to download files for you.

WARNING:
it stores your USERNAME and PASSWORD for
lixian.vip.xunlei.com as PLAINTEXT at ~/.xunlei/credentials.yml
There's not much we can do though.

Install:
-----------

    # you might need to use sudo
    gem install xunlei

Usage:
-----------

Dump all tasks from web and store them at ~/.xunlei/all_tasks.yml:

    xunlei dump_tasks

Download files as described in ~/.xunlei/all_tasks.yml via wget:

    xunlei download

Download files according to pattern in file names

    xunlei download --only matrix
    xunlei download --except bourne

Add ed2k or magnet link as new task

    xunlei add ed2k_or_magment_link

Add all ed2k or magnet links on given web page as new tasks

    xunlei add_page http://page_with_a_chunk_load_of_links/
    
Google for ed2k and magnet links

    xunlei google Repulsion --with 720p

Search simplecd.org for ed2k links

    xunlei simplecd Vendetta 720p

I am feeling lucky :)

    xunlei lucky KEYWORDS

Pass --help to see more tasks and options

    xunlei --help