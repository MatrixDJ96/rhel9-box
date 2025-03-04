#!/bin/bash

cd $(dirname $0)

./build.sh

echo Uploading RHEL9...
./config/extra/env_toolkit.sh --docker-push

echo Done
