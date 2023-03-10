All command below are to be run inside `./shell/run.sh`.

# Terraform infrastructure

First, `cd infrastructure`.

Init, plan, apply:

    terraform init
    terraform plan -refresh=false
    terraform apply -refresh=false -auto-approve

Connect to fanout web server:

    ssh ubuntu@$(terraform output -raw fanout_address)

# Ansible configuration

First, `cd configuration`.

Ping:

    ansible --inventory inventory.yml web_server -m ping

Plan:

    ansible-playbook --inventory inventory.yml --diff --check playbooks/web-server.yml

Apply:

    ansible-playbook --inventory inventory.yml playbooks/web-server.yml
