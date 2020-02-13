#/bin/bash

set -o errexit

case $1 in
  --list)
    echo "Platforms: "
    docker buildx imagetools inspect jacquev6/draw-turks-head-demo:latest | grep Platform | cut -b 14-
    exit 1;;
  *)
    PLATFORM=$1
esac

echo "Platform: $PLATFORM"

NAME=$(docker buildx imagetools inspect jacquev6/draw-turks-head-demo:latest | grep -B2 $PLATFORM | head -n 1 | cut -b 14-)

docker run --rm --name draw-turks-head-demo --publish 8080:80 $NAME
