#!/bin/bash

set -o errexit
cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1

PUSH=false
NOT_PUSHED_WARNING=" # Image not pushed to hub.docker.io, DO NOT COMMIT"
NO_CACHE=""

while [[ "$#" > 0 ]]
do
  case $1 in
    --push)
      PUSH=true
      NOT_PUSHED_WARNING=""
      ;;
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

echo "-----------------------------------------------------------"
echo "Building jacquev6/infrastructure-tools:main-$VERSION"
echo "-----------------------------------------------------------"

docker build $NO_CACHE --tag jacquev6/infrastructure-tools:main-$VERSION --build-arg version=$VERSION .

# Tag intermediate images to avoid losing them on "docker image prune"
for ID in $(docker image ls --filter label=infrastructure-tools-builder-version=$VERSION --quiet)
do
  docker tag \
    $(docker inspect $(docker inspect $ID --format "{{.Parent}}") --format "{{.Parent}}") \
    infrastructure-tools-builder:main-$VERSION-$(docker inspect $ID --format "{{json .Config.Labels}}" | jq -r '.["infrastructure-tools-builder-stage"]')

  docker image rm $ID
done

if $PUSH
then
  docker push jacquev6/infrastructure-tools:main-$VERSION
fi

sed -i "" \
  -e "s/^INFRASTRUCTURE_TOOLS_VERSION=.*/INFRASTRUCTURE_TOOLS_VERSION=$VERSION$NOT_PUSHED_WARNING/" \
  ../../infra
