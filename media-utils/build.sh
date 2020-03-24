#!/usr/bin/env bash

set -o errexit
cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1

RUN=false
BUILDX=""
PLATFORM=""
PUSH=""
NOT_PUSHED_WARNING=" # Image not pushed to registry, DO NOT COMMIT"
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
NAME=registry.jacquev6.net/media-utils:$VERSION

echo "----------------------------------------------------------"
echo "Building $NAME"
echo "----------------------------------------------------------"

# Make sure we're using BuildKit as described in:
# https://www.docker.com/blog/multi-arch-images/
docker $BUILDX build $NO_CACHE $PLATFORM --tag $NAME $PUSH .

# @todo sed version in client file

if $RUN
then
  echo "---------------------------------------------------------"
  echo "Running $NAME"
  echo "---------------------------------------------------------"

  if ! [ -z $BUILDX ]
  then
    NAME=$(docker buildx imagetools inspect $NAME | grep -B2 "^  Platform:  linux/arm/v7$" | head -n 1 | cut -b 14-)
  fi

  rm -rf /tmp/music-for-media-utils-test
  cp -r ~/music-for-media-utils-test /tmp

  echo "Dry run:"
  docker run --rm --name music_utils \
    --volume /tmp/music-for-media-utils-test:/music \
    $NAME music tidy /music --dry-run
  echo

  echo "First actual run:"
  docker run --rm --name music_utils \
    --volume /tmp/music-for-media-utils-test:/music \
    $NAME music tidy /music
  echo

  echo "Second actual run:"
  docker run --rm --name music_utils \
    --volume /tmp/music-for-media-utils-test:/music \
    $NAME music tidy /music
fi
