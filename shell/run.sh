#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."


secrets_ok=true
for template in secrets/*.template; do
  if [[ ! -f "${template%.template}" ]]; then
    echo "Please create ${template%.template} according to $template"
    secrets_ok=false
  fi
done
$secrets_ok

docker build shell --tag cloud-infrastructure-shell

docker run \
  --rm --interactive --tty \
  --volume "$PWD/secrets/main.id_rsa:/root/.ssh/id_rsa:ro" \
  --volume "$PWD/infrastructure:/project/infrastructure" `# Read-write for 'terraform fmt'` \
  --volume "$PWD/configuration:/project/configuration:ro" \
  --volume "$PWD/secrets:/project/secrets:ro" \
  --workdir /project \
  --env-file secrets/env \
  cloud-infrastructure-shell
