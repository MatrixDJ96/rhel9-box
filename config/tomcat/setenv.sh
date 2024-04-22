#!/usr/bin/env bash

export CATALINA_OPTS="$CATALINA_OPTS \
  -Xms512M -Xmx1024M -server -XX:+UseParallelGC \
  -agentlib:jdwp=transport=dt_socket,address=*:5005,server=y,suspend=n"
