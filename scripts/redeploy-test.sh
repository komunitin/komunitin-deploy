#!/bin/sh

docker stop komunitin-app-test
docker system prune -f
docker pull komunitin/komunitin-app:demo
docker run -p 2030:80 -d --name=komunitin-app-test --restart unless-stopped komunitin/komunitin-app:demo
