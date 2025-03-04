#!/bin/bash

cd $(dirname $0)

echo Downloading RHEL9...
./config/extra/env_toolkit.sh --docker-pull

echo Done
