#!/usr/bin/env bash

source pluginsmaster.sh


SERNAME=DocumentServer
PACKAGE_TYPE='onlyoffice-documentserver-ee'
JSON_EXE=/var/www/onlyoffice/documentserver/npm/json

echo 'Sleep for 90 seconds to wait until documentserver reinitialize himself'
sleep 90

docker exec -it $SERNAME $JSON_EXE -f /etc/onlyoffice/documentserver/default.json -I -e 'this.services.CoAuthoring.expire.sessionidle="1h"'
docker exec -it $SERNAME $JSON_EXE -f /etc/onlyoffice/documentserver/default.json -I -e 'this.services.CoAuthoring.autoAssembly.enable=true'
docker exec -it $SERNAME $JSON_EXE -f /etc/onlyoffice/documentserver/default.json -I -e 'this.services.CoAuthoring.server.tokenRequiredParams=false'
docker exec -it $SERNAME $JSON_EXE -f /etc/onlyoffice/documentserver/default.json -I -e 'this.services.CoAuthoring.expire.files=3600'
docker exec -it $SERNAME $JSON_EXE -f /etc/onlyoffice/documentserver/default.json -I -e 'this.FileConverter.converter.errorfiles="error"'

docker exec -it $SERNAME sed -i 's/WARN/ALL/g' /etc/onlyoffice/documentserver/log4js/production.json
docker exec -it $SERNAME sed 's,autostart=false,autostart=true,' -i /etc/supervisor/conf.d/ds-example.conf
docker exec -it $SERNAME sed -i 's,access_log off,access_log /var/log/onlyoffice/documentserver/nginx.access.log,' /etc/onlyoffice/documentserver/nginx/includes/ds-common.conf
_install_plugins $SERNAME
docker exec -it $SERNAME dpkg-query --showformat='${Version}\n' --show $PACKAGE_TYPE
