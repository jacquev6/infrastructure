#/bin/bash

set -o errexit

TAG=$(date "+%Y%m%d-%H%M%S")

echo "--------------------------------------------"
echo "Building jacquev6/infrastructure-tools:$TAG"
echo "--------------------------------------------"

docker build --tag jacquev6/infrastructure-tools:$TAG .

docker push jacquev6/infrastructure-tools:$TAG

sed -i -e "s/^INFRASTRUCTURE_TOOLS_TAG=.*/INFRASTRUCTURE_TOOLS_TAG=$TAG/" ../infra.sh
