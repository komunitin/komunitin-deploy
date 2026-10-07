# Komunitin Deployment
Workflow and utils for the production depployments of https://komunitin.org and https://demo.komunitin.org.

### Reverse proxy
Shared by production and demo. Start this stack first: it creates the `komunitin.org` and `demo.komunitin.org` networks.
```bash
cd proxy
docker compose up -d
```

### Maintenance
From the repository root, configure the production domains and allowed migration clients:
```bash
cd maintenance
cp .env.template .env
vim .env
docker compose up -d
```

`MAINTENANCE_BYPASS` should include include:
 - The operator IP for both Cloudflare and direct requests ``ClientIP(`OPERATOR_IP`) || Header(`CF-Connecting-IP`, `OPERATOR_IP`)``.
 - The docker network subnet ``ClientIP(`172.16.0.0/12`)``.
 - Localhost ``ClientIP(`127.0.0.1`)``.

Run `docker compose down` from `maintenance/` to reopen production.
