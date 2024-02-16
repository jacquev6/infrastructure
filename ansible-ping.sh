#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/."


shell/run.sh bash -c """
set -o errexit
set -o nounset
set -o pipefail


cd infrastructure/configuration

ansible --inventory inventory.yml all -m ping
"""
