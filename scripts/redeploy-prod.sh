#!/bin/sh

docker stop komunitin-app
docker system prune -f
docker pull komunitin/komunitin-app:latest
docker run -p 2028:80 -d --name=komunitin-app --restart unless-stopped komunitin/komunitin-app:latest
