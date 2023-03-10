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
  --volume "$PWD:/wd" --workdir /wd/infrastructure \
  --env-file secrets/env \
  cloud-infrastructure-shell \
    "$@"
