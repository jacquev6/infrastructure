#/bin/bash

set -o errexit

PUSH=false
NOT_PUSHED_WARNING=" # Image not pushed to hub.docker.io, do not commit and most importantly DO NOT APPLY TO PROD"
NO_CACHE=""

while [[ "$#" > 0 ]]
do
  case $1 in
    --push)
      PUSH=true
      NOT_PUSHED_WARNING=""
      ;;
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

docker build $NO_CACHE --tag jacquev6/draw-turks-head-demo:$TAG .
docker tag jacquev6/draw-turks-head-demo:$TAG jacquev6/draw-turks-head-demo:latest

if $PUSH
then
  docker push jacquev6/draw-turks-head-demo:$TAG
fi

sed -i -e "s|image: jacquev6/draw-turks-head-demo:.*|image: jacquev6/draw-turks-head-demo:$TAG$NOT_PUSHED_WARNING|" ../sources/charts/main/templates/draw-turks-head-demo.yaml
