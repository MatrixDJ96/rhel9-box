#!/bin/bash

cd $(dirname $0)

./pull.sh

./run.sh

./install_virtualhosts.sh
./install_ssh_key.sh
