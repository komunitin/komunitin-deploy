# Komunitin Deployment
Production deployment scripts for Komunitin at https://komunitin.org

## Deployment

### Configure

Copy and edit the `.env` file:
```bash	
$ cp .env.template .env
```

Copy the Firebase admin SDK key file to `komunitin-project-firebase-adminsdk.json`.

### Update & start services
```bash	
$ docker compose up -d --build
```

### Reverse proxy
Shared by production and demo. Start this stack first: it creates the `komunitin.org` and `demo.komunitin.org` networks, which the application and maintenance stacks reference as external. Keep the Compose project name `proxy` to reuse the existing `proxy_letsencrypt` certificate volume.
```bash
cd proxy
docker compose up -d
```

### Maintenance
From the repository root, configure the production domains and allowed migration clients:
```bash
cd maintenance
cp .env.template .env
nano .env
docker compose up -d
```

`MAINTENANCE_BYPASS` includes the operator IP `185.247.170.185` for both Cloudflare and direct requests. Add the migration server's public IP if its requests go through Cloudflare, using another ``Header(`CF-Connecting-IP`, `SERVER_IP`)`` matcher.

For containers calling production domains directly through Traefik, append `` || ClientIP(`ACTUAL_SUBNET`)`` using the production network subnet returned by this command on the production server:
```bash
docker network inspect komunitin.org --format '{{range .IPAM.Config}}{{println .Subnet}}{{end}}'
```
This permits every container on that subnet to bypass maintenance. `127.0.0.1` is only useful if Traefik actually sees a loopback client; host requests to Docker-published ports can appear with a Docker gateway address instead. `ClientIP` matches the immediate client address, not forwarded headers.

Run `docker compose down` from `maintenance/` to reopen production. See `MIGRATION.md` in the main Komunitin repository for the migration sequence and worker shutdown.
