#/bin/bash

# Install webhook at http://<host>/hooks/redeploy
sudo webhook -hooks /opt/komunitin-deploy/webhook/hooks.json -verbose
