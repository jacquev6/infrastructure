#/bin/bash

set -o errexit

DATE_TAG=$(date "+%Y%m%d-%H%M%S")
HOST_TAG=latest-built-on-$(hostname)

echo "--------------------------------------------"
echo "Building jacquev6/draw-turks-head-demo:$DATE_TAG"
echo "--------------------------------------------"

docker build --tag jacquev6/draw-turks-head-demo:$DATE_TAG .
docker tag jacquev6/draw-turks-head-demo:$DATE_TAG jacquev6/draw-turks-head-demo:$HOST_TAG

# Keep one image built by each host. This way all `docker push`es will have as many "Layer already exists" as possible.
docker push jacquev6/draw-turks-head-demo:$HOST_TAG
# Images tagged with a date can all be deleted except the last one.
docker push jacquev6/draw-turks-head-demo:$DATE_TAG
