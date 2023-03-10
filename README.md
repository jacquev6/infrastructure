Init, plan, apply:

    ./shell/run.sh terraform init
    ./shell/run.sh terraform plan
    ./shell/run.sh terraform apply

Connect to fanout web server:

    ./shell/run.sh ssh ubuntu@$(./shell/run.sh terraform output -raw fanout_address)

Or, from within `./shell/run.sh`:

    ssh ubuntu@$(terraform output -raw fanout_address)
