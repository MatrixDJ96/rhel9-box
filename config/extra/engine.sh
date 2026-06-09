#!/bin/bash

# Container engine selection shared across the host-side scripts.
# Source this file, then use "${ENGINE}" for every container command.
# Override with ENGINE=docker|podman, otherwise prefer podman.
if [ -z "${ENGINE:-}" ]; then
  if command -v podman >/dev/null 2>&1; then
    ENGINE=podman
  else
    ENGINE=docker
  fi
fi
