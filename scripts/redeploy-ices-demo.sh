#!/bin/bash

# Reinstall IntegralCES demo.

export ICES_SITE_NAME="IntegralCES Demo"
export ICES_ADMIN_PASSWORD="demo@ices2030"
export ICES_MYSQL_PASSWORD="demo@ices2030"

cd /opt/ices
docker compose down --volumes
git pull
docker compose up -d --build
sleep 3
./install.sh --demo

# Add settings for proxy-pass and mail
docker compose exec integralces printf "\n\
// Configure reverse proxy.\n\
$conf['reverse_proxy'] = TRUE;\n\
$conf['reverse_proxy_addresses'] = ['172.17.0.1'];\n\
$base_url = 'https://demo.integralces.net';\n\
\n\
// Configure mailing (disabled)\n\
$conf['smtp_allowhtml'] = 1;\n\
$conf['smtp_deliver'] = 0;\n\
$conf['smtp_on'] = 1;\n\
" >> sites/default/settings.php

# Add front page message.
FRONT_DEMO_CONTENT = "\n\
  <p style='color:black;'><i><?php print t('This is a demo site. Login as user:'); ?><br>\n\
  <?php print t('NET1: Gauss, Euclides, Riemann (admin).'); ?><br>\n\
  <?php print t('NET2: Gauss, Noether, Fermat (admin).'); ?><br>\n\
  <?php print t('All passwords are "integralces"'); ?></i></p>\n\
"
RUN sed -i "/social currencies management for communities./a $FRONT_DEMO_CONTENT" sites/all/themes/greences/templates/page.tpl.php
