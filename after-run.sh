#!/usr/bin/env bash

PACKAGE_TYPE='onlyoffice-documentserver-ee'
echo 'Sleep for 90 seconds to wait until documentserver reinitialize himself'
sleep 90
JSON_EXE=/var/www/onlyoffice/documentserver/npm/json

docker exec -it DocumentServer $JSON_EXE -f /etc/onlyoffice/documentserver/default.json -I -e 'this.services.CoAuthoring.expire.sessionidle="1h"'
docker exec -it DocumentServer $JSON_EXE -f /etc/onlyoffice/documentserver/default.json -I -e 'this.services.CoAuthoring.autoAssembly.enable=true'

docker exec -it DocumentServer sed -i 's/WARN/ALL/g' /etc/onlyoffice/documentserver/log4js/production.json
docker exec -it DocumentServer sed 's,autostart=false,autostart=true,' -i /etc/supervisor/conf.d/ds-example.conf
docker exec -it DocumentServer sed -i 's,access_log off,access_log /var/log/onlyoffice/documentserver/nginx.access.log,' /etc/onlyoffice/documentserver/nginx/includes/ds-common.conf
docker cp plugins-install.sh DocumentServer:/tmp
docker exec -it DocumentServer bash /tmp/plugins-install.sh
docker exec -it DocumentServer service nginx restart
docker exec -it DocumentServer supervisorctl restart all
docker exec -it DocumentServer dpkg-query --showformat='${Version}\n' --show $PACKAGE_TYPE
