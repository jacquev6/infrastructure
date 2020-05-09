#!/usr/bin/env bash

set -o errexit
cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1

run=false
buildx=""
platform=""
push=""
not_pushed_warning=" # Image not pushed to registry, DO NOT COMMIT"
no_cache=""

while [[ "$#" > 0 ]]
do
  case $1 in
    --run)
      run=true
      ;;
    --runx)
      run=true
      ;& # https://riptutorial.com/bash/example/18601/case-statement-with-fall-through
    --push)
      buildx="buildx"
      platform="--platform linux/amd64,linux/arm/v7,linux/arm64/v8"
      push="--push"
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
name=registry.jacquev6.net/periodical-check-bot:$version

echo "-------------------------------------------------------------------"
echo "Building $name"
echo "-------------------------------------------------------------------"

# Make sure we're using BuildKit as described in:
# https://www.docker.com/blog/multi-arch-images/
docker $buildx build $no_cache $platform --tag $name $push .

sed -i "" \
  -e "s/^  periodical_check_bot_version = .*/  periodical_check_bot_version = \"$version\"$not_pushed_warning/" \
  ../terraform/resources/butler_containers/periodical_check_bot.tf

if $run
then
  echo "------------------------------------------------------------------"
  echo "Running $name"
  echo "------------------------------------------------------------------"

  if ! [ -z $buildx ]
  then
    name=$(docker buildx imagetools inspect $name | grep -B2 "^  Platform:  linux/arm/v7$" | head -n 1 | cut -b 14-)
  fi

  docker run --rm --name periodical_check_bot \
    --volume $HOME/.ssh/id_rsa:/root/.ssh/id_rsa:ro \
    --volume $HOME/.ssh/known_hosts:/etc/ssh/ssh_known_hosts:ro \
    $name jacquev6 idee.home.jacquev6.net jacquev6@gmail.com --delay 1800
fi
