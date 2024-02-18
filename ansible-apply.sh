#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/."


shell/run.sh bash -c '''
set -o errexit
set -o nounset
set -o pipefail


cd configuration

detect_reachable_playbook=$(find playbooks -name '????-detect-reachable.yml')

find playbooks -name '*.yml' | sort -n | while read playbook
do
  echo "PLAYBOOK [$playbook] ****************************************************"
  ansible-playbook --inventory inventory $playbook || [ $playbook == $detect_reachable_playbook ]
done
'''
