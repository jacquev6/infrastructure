#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."


if [[ ! -f shell/secrets.env ]]; then
  echo "Please create shell/secrets.env according to shell/secrets.env.template"
  exit 1
fi

docker build shell --tag cloud-infrastructure-shell

docker run \
  --rm --interactive --tty \
  --volume "$PWD:/wd" --workdir /wd/infrastructure \
  --env-file shell/secrets.env \
  cloud-infrastructure-shell \
    "$@"
