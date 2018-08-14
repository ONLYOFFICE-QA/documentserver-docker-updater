echo 'Sleep for 30 seconds to wait until documentserver reinitialize himself'
sleep 30

docker exec -it doc-linux json -f /etc/onlyoffice/documentserver/defaul.json -I -e 'this.services.CoAuthoring.expire.sessionidle="1h"'

docker exec -it doc-linux sed -i 's/WARN/ALL/g' /etc/onlyoffice/documentserver/log4js/production.json
docker exec -it doc-linux supervisorctl restart all
docker cp archive-share-libs.sh doc-linux:/tmp/archive-share-libs.sh
docker exec -it doc-linux bash /tmp/archive-share-libs.sh
docker exec -it doc-linux dpkg-query --showformat='${Version}\n' --show onlyoffice-documentserver-ie
