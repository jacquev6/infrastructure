#!/bin/bash

set -o errexit
cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1

NO_CACHE=""

while [[ "$#" > 0 ]]
do
  case $1 in
    --no-cache)
      NO_CACHE="--no-cache --pull"
      ;;
    *)
      echo "Unknown parameter passed: $1"
      exit 1;;
  esac
  shift
done

VERSION=$(date "+%Y%m%d-%H%M%S")

echo "------------------------------------------------------"
echo "Building jacquev6/draw-turks-head-demo:$VERSION"
echo "------------------------------------------------------"

# @todo Have a look at https://lobradov.github.io/Building-docker-multiarch-images/#same-dockerfile-template
# It could allow building multi-arch without BuildKit, and not needing to push/pull to test

# Make sure we're using BuildKit as described in:
# https://www.docker.com/blog/multi-arch-images/
# @todo (when https://github.com/moby/moby/pull/38738 actually solves https://github.com/docker/buildx/issues/59): use --load by default and re-add the --push option to this script
docker buildx build \
  $NO_CACHE \
  --platform linux/amd64,linux/arm/v7 \
  --tag jacquev6/draw-turks-head-demo:latest --tag jacquev6/draw-turks-head-demo:$VERSION \
  --push \
  .

sed -i "" \
  -e "s/^  draw_turks_head_demo_version = .*/  draw_turks_head_demo_version = \"$VERSION\"/" \
  ../sources/resources/doorman_containers/doorman_containers.tf
