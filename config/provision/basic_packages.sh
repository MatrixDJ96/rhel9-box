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

yum -y install \
  btop
