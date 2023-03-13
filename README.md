This [infrastructure as code](https://en.wikipedia.org/wiki/Infrastructure_as_code) repository manages the infrastructure I use at various "cloud" providers.
It's complementary to my [home-infrastructure](https://github.com/jacquev6/home-infrastructure) repository.

It uses [Terraform](https://www.terraform.io/) to create the infrastructure itself ([AWS](https://aws.amazon.com/), [Gandi](https://www.gandi.net/), [UptimeRobot](uptimerobot.com/)) and [Ansible](https://www.ansible.com/) to install software and configure [Docker Compose](https://docs.docker.com/compose/) environments.

# Usage

All command below are to be run inside `./shell/run.sh`.

## Terraform infrastructure

First, `cd infrastructure`.

Init, plan, apply:

    terraform init
    terraform plan -refresh=false
    terraform apply -refresh=false -auto-approve

Connect to fanout web server:

    ssh ubuntu@$(terraform output -raw fanout_address)

## Ansible configuration

First, `cd configuration`.

Ping:

    ansible --inventory inventory.yml web_server -m ping

Plan:

    ansible-playbook --inventory inventory.yml --diff --check playbooks/web-server.yml

Apply:

    ansible-playbook --inventory inventory.yml playbooks/web-server.yml
