#!/bin/bash

set -o errexit
cd "$(dirname "${BASH_SOURCE[0]}")"
. ../_utils.sh

no_cache=""
do_build=true
do_push=false
do_deploy=false

while [[ "$#" > 0 ]]
do
  case $1 in
    --no-cache)
      no_cache="--no-cache --pull"
      ;;
    --push)
      do_push=true
      ;;
    --deploy)
      do_deploy=true
      ;;
    *)
      echo "Unknown parameter passed: $1"
      exit 1;;
  esac
  shift
done

if $do_build
then
  title "Building with tag latest"

  for dockerfile in $(find docker -name Dockerfile)
  do
    image_name=${dockerfile#docker/}
    image_name=media-utils/${image_name%/Dockerfile}
    docker build $no_cache --file $dockerfile --tag $image_name:latest .
  done
fi

if $do_push
then
  title "Pushing with tag $now"

  for dockerfile in $(find docker -name Dockerfile)
  do
    image_name=${dockerfile#docker/}
    image_name=media-utils/${image_name%/Dockerfile}
    docker tag $image_name:latest registry.jacquev6.net/$image_name:$now
    docker push registry.jacquev6.net/$image_name:$now
    docker image rm registry.jacquev6.net/$image_name:$now
  done

  sed -i "" "s/........-......  # media-utils-version/$now  # media-utils-version/g" ../ansible/playbooks/100-media-utils.yml
fi

if $do_deploy
then
  title "Deploying on idee"

  ../infra an apply -pb playbooks/100-media-utils.yml idee
fi
