#!/bin/bash

cd $(dirname $0)

echo Importing RHEL9...
./config/extra/env_toolkit.sh --docker-import

echo Done
