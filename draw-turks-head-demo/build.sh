#!/usr/bin/env bash

set -o errexit
cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1

RUN=false
BUILDX=""
PLATFORM=""
PUSH=""
NOT_PUSHED_WARNING=" # Image not pushed to hub.docker.io, DO NOT COMMIT"
NO_CACHE=""

while [[ "$#" > 0 ]]
do
  case $1 in
    --run)
      RUN=true
      ;;
    --runx)
      RUN=true
      ;& # https://riptutorial.com/bash/example/18601/case-statement-with-fall-through
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
NAME=jacquev6/draw-turks-head-demo:$VERSION

echo "------------------------------------------------------"
echo "Building $NAME"
echo "------------------------------------------------------"

# Make sure we're using BuildKit as described in:
# https://www.docker.com/blog/multi-arch-images/
docker $BUILDX build $NO_CACHE $PLATFORM --tag $NAME $PUSH .

sed -i "" \
  -e "s/^  draw_turks_head_demo_version = .*/  draw_turks_head_demo_version = \"$VERSION\"$NOT_PUSHED_WARNING/" \
  ../sources/resources/butler_containers/butler_containers.tf

if $RUN
then
  echo "----------------------------------------------------"
  echo "Runing $NAME"
  echo "----------------------------------------------------"


  if ! [ -z $BUILDX ]
  then
    NAME=$(docker buildx imagetools inspect $NAME | grep -B2 "^  Platform:  linux/arm/v7$" | head -n 1 | cut -b 14-)
  fi

  docker run --rm --name draw_turks_head_demo --publish 8080:80 $NAME
fi
