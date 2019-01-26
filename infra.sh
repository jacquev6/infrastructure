#!/bin/bash

set -o errexit

INFRASTRUCTURE_TOOLS_TAG=20190126-080813

docker run --interactive --tty \
  --mount type=bind,src=$PWD/sources,dst=/sources \
  --mount type=bind,src=$HOME/.ssh,dst=/ssh,readonly \
  jacquev6/infrastructure-tools:$INFRASTRUCTURE_TOOLS_TAG \
  -- "$@"

# @todo Could we avoid that?
# Internet doesn't seem to know how to make `docker --mount` use current user.
# Maybe we should pass numerical user and group ids to the container and do the change there?
sudo chown -R $(id -nu):$(id -ng) sources
