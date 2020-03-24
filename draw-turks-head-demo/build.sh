#!/usr/bin/env bash

set -o errexit
cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1

MINIMIZE_LIST=false
RUN=false
BUILDX=""
PLATFORM=""
PUSH=""
NOT_PUSHED_WARNING=" # Image not pushed to registry, DO NOT COMMIT"
NO_CACHE=""

while [[ "$#" > 0 ]]
do
  case $1 in
    --mini-list)
      MINIMIZE_LIST=true
      ;;
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


if $MINIMIZE_LIST
then
  echo "-------------------"
  echo "Minimizing list.txt"
  echo "-------------------"

  IMAGE=$(docker build --quiet .)

  port=8000
  rm -f list-minimized.txt
  for f in $(cat list.txt)
  do
    echo "$f"

    if [ $port -ge 8100 ]
    then
      port=8000
    fi

    if [ $port -eq 8000 ]
    then
      docker kill minimize_draw_turks_head_demo_list >/dev/null 2>/dev/null || true
      docker run --detach --rm --name minimize_draw_turks_head_demo_list $IMAGE >/dev/null
      sleep 2
      rm -rf /tmp/minimizing
      docker cp minimize_draw_turks_head_demo_list:/ /tmp/minimizing
      touch /tmp/minimizing/empty
    fi

    # We don't have a way to delete a file inside the container => truncate it
    docker cp /tmp/minimizing/empty minimize_draw_turks_head_demo_list:$f

    port=$(expr $port + 1)
    set +o errexit
    # Gunicorn will stay up more that the timeout iif it starts successfully
    gtimeout 1s \
      docker exec minimize_draw_turks_head_demo_list \
      gunicorn -w 1 -b :$port wsgi:app >/dev/null 2>/dev/null
    ret=$?
    set -o errexit
    if [ $ret -ne 124 ]
    then
      docker cp /tmp/minimizing$f minimize_draw_turks_head_demo_list:$f
      echo $f >>list-minimized.txt
    fi
  done

  docker kill minimize_draw_turks_head_demo_list
  mv list-minimized.txt list.txt
fi


echo "------------------------------------------------------"
echo "Building $NAME"
echo "------------------------------------------------------"

# Make sure we're using BuildKit as described in:
# https://www.docker.com/blog/multi-arch-images/
docker $BUILDX build $NO_CACHE $PLATFORM --tag $NAME $PUSH .

sed -i "" \
  -e "s/^  draw_turks_head_demo_version = .*/  draw_turks_head_demo_version = \"$VERSION\"$NOT_PUSHED_WARNING/" \
  ../terraform/resources/butler_containers/draw_turks_head_demo.tf

if $RUN
then
  echo "-----------------------------------------------------"
  echo "Running $NAME"
  echo "-----------------------------------------------------"

  if ! [ -z $BUILDX ]
  then
    NAME=$(docker buildx imagetools inspect $NAME | grep -B2 "^  Platform:  linux/arm/v7$" | head -n 1 | cut -b 14-)
  fi

  docker run --rm --name draw_turks_head_demo --publish 8080:80 $NAME
fi
