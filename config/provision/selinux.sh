#!/bin/bash

yum -y install \
  selinux-policy \
  selinux-policy-targeted \
  policycoreutils \
  policycoreutils-python-utils \
  libselinux-utils

setenforce 0

sed -i 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config
sed -i 's/^SELINUXTYPE=.*/SELINUXTYPE=targeted/' /etc/selinux/config
