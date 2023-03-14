#!/bin/sh

docker-compose --project-name komunitin-prod --file /opt/komunitin-deploy/docker-compose.prod.yml up -d
