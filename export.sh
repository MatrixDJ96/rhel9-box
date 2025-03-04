#!/bin/bash

cd $(dirname $0)

echo Exporting RHEL9...
./config/extra/env_toolkit.sh --docker-export

echo Done
