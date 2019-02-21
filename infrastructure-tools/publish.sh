#/bin/bash

set -o errexit

PUSH=false

while [[ "$#" > 0 ]]
do
  case $1 in
    --push)
      PUSH=true
      ;;
    *)
      echo "Unknown parameter passed: $1"
      exit 1;;
  esac
  shift
done

DATE_TAG=$(date "+%Y%m%d-%H%M%S")
HOST_TAG=latest-built-on-$(hostname)

echo "--------------------------------------------"
echo "Building jacquev6/infrastructure-tools:$DATE_TAG"
echo "--------------------------------------------"

docker build --tag jacquev6/infrastructure-tools:$DATE_TAG .
docker tag jacquev6/infrastructure-tools:$DATE_TAG jacquev6/infrastructure-tools:$HOST_TAG

if $PUSH
then
  # Keep one image built by each host. This way all `docker push`es will have as many "Layer already exists" as possible.
  docker push jacquev6/infrastructure-tools:$HOST_TAG
  # Images tagged with a date can all be deleted except the last one.
  docker push jacquev6/infrastructure-tools:$DATE_TAG
fi

NOT_PUSHED_WARNING=""

if ! $PUSH
then
  NOT_PUSHED_WARNING=" # Image not pushed to hub.docker.io, DO NOT COMMIT"
fi

sed -i -e "s/^INFRASTRUCTURE_TOOLS_TAG=.*/INFRASTRUCTURE_TOOLS_TAG=$DATE_TAG$NOT_PUSHED_WARNING/" ../infra
