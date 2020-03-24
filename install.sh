#/bin/bash

# Install webhook micro server
sudo apt-get install webhook

# Copy the hooks file.
sudo cp /opt/komunitin-deploy/webhook/hooks.json /etc/webhook.conf

# Restart webhook
sudo service webhook restart