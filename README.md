# komunitin-deploy
Deployment scripts for Komunitin & integralCES

## DEMO
### Komunitin (https://demo.komunitin.org)
Install/Update Komunitin from images. Clears all data.
```
$ scripts/redeploy-test.sh
```
### IntegralCES (https://demo.integralces.net)
Install/Update IntegralCES from the `ices` repository located at `/opt/ices`. Clears all data.
```
$ scripts/redeploy-ices-demo.sh
```

## PRODUCTION
### Komunitin (https://komunitin.org)
Install/Update Komunitin from images.
```
$ scripts/redeploy-prod.sh
```
### IntegralCES (https://integralces.net)
Install/Update IntegralCES from the `/ices` folder. Maintains database data in volume ices-data.
$ cd ices
$ docker compose up -d
```
