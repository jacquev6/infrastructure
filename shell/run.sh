#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."


secrets_ok=true
echo "# Secrets" > .gitignore
find . -name '*.secret_template' | while read template; do
  secret="${template%.secret_template}"
  secret="${secret#./}"
  echo "$secret" >> .gitignore
  if [[ ! -f "$secret" ]]; then
    echo "Please create $secret according to $template"
    secrets_ok=false
  fi
done
$secrets_ok

chmod 600 configuration/ssh/id_rsa

user_name=$(whoami)
user_id=$(id -u)
docker build --build-arg USER_NAME=$user_name --build-arg USER_ID=$user_id shell --tag infrastructure-shell

docker run \
  --rm --interactive --tty \
  --volume "$PWD/configuration/ssh/:/home/$user_name/.ssh/" \
  --volume "$PWD:/project" --workdir /project \
  --env-file provisioning/credentials.env \
  infrastructure-shell "$@"
