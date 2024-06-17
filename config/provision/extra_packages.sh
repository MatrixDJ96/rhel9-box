#!/bin/bash

yum -y install \
  cabextract \
  fontconfig \
  mkfontscale \
  mkfontdir \
  xset

yum -y install \
  https://repo.almalinux.org/almalinux/9/devel/x86_64/os/Packages/xorg-x11-font-utils-7.5-53.el9.x86_64.rpm \
  https://repo.almalinux.org/almalinux/9/AppStream/x86_64/os/Packages/xorg-x11-fonts-75dpi-7.5-33.el9.noarch.rpm \
  https://repo.almalinux.org/almalinux/9/AppStream/x86_64/os/Packages/xorg-x11-fonts-Type1-7.5-33.el9.noarch.rpm

yum -y install \
  https://downloads.sourceforge.net/project/mscorefonts2/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm \
  https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-2/wkhtmltox-0.12.6.1-2.almalinux9.x86_64.rpm
