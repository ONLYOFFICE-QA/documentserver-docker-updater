echo 'Sleep for 30 seconds to wait until documentserver reinitialize himself'
sleep 30
JSON_EXE=/var/www/onlyoffice/documentserver/npm/json

docker exec -it doc-linux $JSON_EXE -f /etc/onlyoffice/documentserver/default.json -I -e 'this.services.CoAuthoring.expire.sessionidle="1h"'
docker exec -it doc-linux $JSON_EXE -f /etc/onlyoffice/documentserver/default.json -I -e 'this.services.CoAuthoring.autoAssembly.enable=true'

docker exec -it doc-linux sed -i 's/WARN/ALL/g' /etc/onlyoffice/documentserver/log4js/production.json
docker exec -it doc-linux sed 's,autostart=false,autostart=true,' -i /etc/supervisor/conf.d/ds-example.conf
docker exec -it doc-linux sed -i 's,access_log off,access_log /var/log/onlyoffice/documentserver/nginx.access.log,' /etc/onlyoffice/documentserver/nginx/includes/ds-common.conf
docere exec -it doc-linux service nginx restart
docker exec -it doc-linux supervisorctl restart all
docker exec -it doc-linux dpkg-query --showformat='${Version}\n' --show onlyoffice-documentserver-ie
