#/bin/bash

set -o errexit

DATE_TAG=$(date "+%Y%m%d-%H%M%S")
HOST_TAG=latest-built-on-$(hostname)

echo "--------------------------------------------"
echo "Building jacquev6/infrastructure-tools:$DATE_TAG"
echo "--------------------------------------------"

docker build --tag jacquev6/infrastructure-tools:$DATE_TAG .
docker tag jacquev6/infrastructure-tools:$DATE_TAG jacquev6/infrastructure-tools:$HOST_TAG

# Keep one image built by each host. This way all `docker push`es will have as many "Layer already exists" as possible.
docker push jacquev6/infrastructure-tools:$HOST_TAG
# Images tagged with a date can all be deleted except the last one.
docker push jacquev6/infrastructure-tools:$DATE_TAG

sed -i -e "s/^INFRASTRUCTURE_TOOLS_TAG=.*/INFRASTRUCTURE_TOOLS_TAG=$DATE_TAG/" ../infra.sh
