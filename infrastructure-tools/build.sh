#/bin/bash

set -o errexit

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
echo "Building jacquev6/infrastructure-tools:$TAG"
echo "------------------------------------------------------"

docker build $NO_CACHE --tag jacquev6/infrastructure-tools:$TAG .
docker tag jacquev6/infrastructure-tools:$TAG jacquev6/infrastructure-tools:latest

if $PUSH
then
  docker push jacquev6/infrastructure-tools:$TAG
fi

sed -i -e "s/^INFRASTRUCTURE_TOOLS_TAG=.*/INFRASTRUCTURE_TOOLS_TAG=$TAG$NOT_PUSHED_WARNING/" ../infra
