# komunitin-deploy
Testing deploy scripts for Continuous Delivery

## Requirements
The target server where the Komunitin app will be deployed must meet the following requirements:
 - Ubuntu linux distribution
 - Docker engine ([official instructions](https://docs.docker.com/install/linux/docker-ce/ubuntu/))
 - Clone this repository in the `/opt` folder.

## Install
Run the script `install.sh` from a sudoer user. It will install the [Webhook](https://github.com/adnanh/webhook) server at port `9000`.

 
 
