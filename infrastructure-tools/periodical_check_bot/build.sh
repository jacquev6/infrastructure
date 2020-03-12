#!/bin/bash

set -o errexit
cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1

BUILDX=""
PLATFORM=""
PUSH=""
NOT_PUSHED_WARNING=" # Image not pushed to hub.docker.io, DO NOT COMMIT"
NO_CACHE=""

while [[ "$#" > 0 ]]
do
  case $1 in
    --push)
      BUILDX="buildx"
      PLATFORM="--platform linux/amd64,linux/arm/v7"
      PUSH="--push"
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

echo "---------------------------------------------------------------------------"
echo "Building jacquev6/infrastructure-tools:periodical_check_bot-$VERSION"
echo "---------------------------------------------------------------------------"

docker $BUILDX build \
  $NO_CACHE \
  $PLATFORM \
  --tag jacquev6/infrastructure-tools:periodical_check_bot-latest --tag jacquev6/infrastructure-tools:periodical_check_bot-$VERSION \
  $PUSH \
  .

sed -i "" \
  -e "s/^  periodical_check_bot_version = .*/  periodical_check_bot_version = \"$VERSION\"$NOT_PUSHED_WARNING/" \
  ../../sources/resources/doorman_containers/doorman_containers.tf
