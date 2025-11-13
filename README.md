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
Either use the provided Traefik reverse proxy or configure your own.
```bash
$ docker compose -f traefik.yml up -d
```

