#!/bin/bash

# Clean cache yum
yum clean all

# Clean tmp files
find /tmp -mindepth 1 -type f -exec rm -f {} \;
find /var/tmp -mindepth 1 -type f -exec rm -f {} \;

# Clean cache files
find /var/cache -type f -exec rm -f {} \;

# Clean log files
find /var/log -type f -name "*.log*" -exec rm -f {} \;
