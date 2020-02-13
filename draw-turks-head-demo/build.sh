#/bin/bash

set -o errexit

NO_CACHE=""

while [[ "$#" > 0 ]]
do
  case $1 in
    --no-cache)
      NO_CACHE=--no-cache
      ;;
    *)
      echo "Unknown parameter passed: $1"
      exit 1;;
  esac
  shift
done

TAG=$(date "+%Y%m%d-%H%M%S")

echo "------------------------------------------------------"
echo "Building jacquev6/draw-turks-head-demo:$TAG"
echo "------------------------------------------------------"

# @todo Have a look at https://lobradov.github.io/Building-docker-multiarch-images/#same-dockerfile-template
# It could allow building multi-arch without BuildKit, and not needing to push/pull to test

# Make sure we're using BuildKit as described in:
# https://www.docker.com/blog/multi-arch-images/
# @todo (when https://github.com/moby/moby/pull/38738 actually solves https://github.com/docker/buildx/issues/59): use --load by default and re-add the --push option to this script
docker buildx build \
  $NO_CACHE \
  --platform linux/amd64,linux/arm/v7 \
  --tag jacquev6/draw-turks-head-demo:latest --tag jacquev6/draw-turks-head-demo:$TAG \
  --push \
  .

sed -i "" \
  -e "s|name = \"jacquev6/draw-turks-head-demo:.*|name = \"jacquev6/draw-turks-head-demo:$TAG\"|" \
  -e "s|pull_triggers = \[\"jacquev6/draw-turks-head-demo:.*|pull_triggers = [\"jacquev6/draw-turks-head-demo:$TAG\"]|" \
  ../sources/resources/doorman_containers/doorman_containers.tf

sed -i "" \
  -e "s|image: jacquev6/draw-turks-head-demo:.*|image: jacquev6/draw-turks-head-demo:$TAG|" \
  ../sources/charts/main/templates/draw-turks-head-demo.yaml
