#!/bin/bash

yum -y install \
  autoconf \
  automake \
  binutils \
  gcc \
  gcc-c++ \
  gdb \
  glibc-devel \
  libtool \
  make \
  pkgconf \
  pkgconf-m4 \
  pkgconf-pkg-config \
  redhat-rpm-config \
  rpm-build \
  strace

yum -y install \
  git \
  perl-Fedora-VSP \
  perl-generators \
  source-highlight \
  valgrind \
  valgrind-devel

yum -y install \
  procps-ng \
  hostname \
  iputils \
  lsof \
  nano \
  openssl \
  pip \
  sudo \
  unzip \
  wget \
  which \
  zip

yum -y install \
  gettext \
  glibc-all-langpacks

if [[ -z "$container" ]]; then
  yum -y install \
    btop \
    htop \
    mlocate
else
  yum -y install \
    btop \
    htop \
    https://repo.almalinux.org/almalinux/9/BaseOS/x86_64/os/Packages/mlocate-0.26-30.el9.x86_64.rpm \
    https://repo.almalinux.org/almalinux/9/BaseOS/x86_64/os/Packages/hwloc-libs-2.4.1-5.el9.x86_64.rpm
fi
