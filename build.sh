#!/bin/bash

cd $(dirname $0)

if [[ -z "$SKIP_BUILD" ]]; then
  read -r -p "Do you want to skip build? [y/N] " SKIP
  if [[ "$SKIP" =~ ^[Yy]$ ]]; then
    export SKIP_BUILD=1
  fi
fi

if [[ -z "$SKIP_BUILD" ]]; then
  echo "Building RHEL9..."
  ./config/extra/env_toolkit.sh --docker-build

  echo Done
fi
