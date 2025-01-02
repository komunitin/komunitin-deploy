OK - Set integralces to maintenance mode
Configuració > Mode de manteniment > Activar

- Disable komunitin app
$ssh webadmin@komunitin.org
$docker stop 1da36780b03f (app container id)

- Backup IntegralCES
$ssh deploy@integralces.net
~$ cd /opt/komunitin-deploy/ices
ices$ docker compose exec ices bash
html# drush arb
> Database dump saved to /tmp/drush_tmp_1735660124_6774125c01fda/c13ices_prod.sql
> Archive saved to /root/drush-backups/archive-dump/20241231154842/c13ices_prod.20241231_154842.tar.gz
/root/drush-backups/archive-dump/20241231154842/c13ices_prod.20241231_154842.tar.gz
html# exit
ices$ docker compose cp ices:~/root/drush-backups/archive-dump/20241231154842/c13ices_prod.20241231_154842.tar.gz ~/integralces-backup.tar.gz

- Backup redis data volume
$ssh webadmin@komunitin.org
komunitin-deploy$ docker compose exec redis redis-cli save 
komunitin-deploy$ docker compose cp redis:/data/dump.rdb ./notifications-backup.rdb
copy backup to vsrver2
$scp notifications-backup.rdb deploy@integralces.net:/home/deploy/


- Stop all services
$ssh webadmin@komunitin.org
komunitin-deploy$ docker compose stop

- Stop IntegralCES services
ices$ docker compose stop

- Stop proxy
cd proxy
proxy$ docker compose down

- Get komunitin-deploy repository into komunitin.org
$ mv komunitin-deploy komunitin-deploy-old
$ git clone git://github.com/komunitin/komunitin-deploy.git
$ cd komunitin-deploy
$ git checkout master

- add .env and .json files
vim .env # copy from local
su ubuntu # 4J3CE3fK4Zny
cp komunitin-deploy-old/komunitin-project-firebase-adminsdk.json .

- add drupal files
$ cp -R ../komunitin-deploy-old/ices/drupal ices/
- chacnge ownership
$ sudo chown -R deploy:deploy .
$ exit

- Start new services
komunitin-deploy$ docker compose up -d

- Check ICES is working and not installed.

- Restore IntegralCES
komunitin-deploy$ docker compose cp ~/integralces-backup.tar.gz ices:~/root/
komunitin-deploy$ docker compose exec integralces bash
html# drush arr /root/integralces-backup.tar.gz

- Check ICES is working and in maintenance mode

- Change *.komunitin.org DNS to new server
Go to GoDaddy and change the A record for *.komunitin.org to the new server IP

- Restore redis data volume
docker compose cp ~/notifications-backup.rdb notifications-db:/data/dump.rdb
docker compose exec notifications-db bash
redis# redis-cli --rdb /data/dump.rdb

- Create accounting DB
docker compose exec accounting pnpm prisma deploy

- Remove Maintenance mode
Configuració > Mode de manteniment > Desactivar

- Check everything is working













