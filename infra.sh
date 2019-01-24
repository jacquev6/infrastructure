#!/bin/bash

set -o errexit

INFRASTRUCTURE_TOOLS_TAG=20190124-221914

docker run --interactive --tty \
  --mount type=bind,src=$PWD/sources,dst=/sources \
  --mount type=bind,src=$HOME/.ssh,dst=/ssh,readonly \
  jacquev6/infrastructure-tools:$INFRASTRUCTURE_TOOLS_TAG \
  -- "$@"

sudo chown -R vincent sources
