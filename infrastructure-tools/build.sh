#!/bin/bash

set -o errexit
cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1

push=false
not_pushed_warning=" # Image not pushed to registry, DO NOT COMMIT"
no_cache=""

while [[ "$#" > 0 ]]
do
  case $1 in
    --push)
      push=true
      not_pushed_warning=""
      ;;
    --no-cache)
      no_cache="--no-cache --pull"
      ;;
    *)
      echo "Unknown parameter passed: $1"
      exit 1;;
  esac
  shift
done

version=$(date "+%Y%m%d-%H%M%S")
name=jacquev6/infrastructure-tools:$version

echo "------------------------------------------------------"
echo "Building $name"
echo "------------------------------------------------------"

docker build $no_cache --tag $name --build-arg version=$version .

# Tag intermediate images to avoid losing them on "docker image prune"
for ID in $(docker image ls --filter label=infrastructure-tools-builder-version=$version --quiet)
do
  docker tag \
    $(docker inspect $(docker inspect $ID --format "{{.Parent}}") --format "{{.Parent}}") \
    infrastructure-tools-builder:$version-$(docker inspect $ID --format "{{json .Config.Labels}}" | jq -r '.["infrastructure-tools-builder-stage"]')

  docker image rm $ID
done

if $push
then
  docker push $name
fi

sed -i "" \
  -e "s/^infrastructure_tools_version=.*/infrastructure_tools_version=$version$not_pushed_warning/" \
  ../infra
