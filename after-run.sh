docker cp ~/local.json doc-linux:/etc/onlyoffice/documentserver/local.json
docker cp ~/config.js doc-linux:/var/www/onlyoffice/documentserver/server/Metrics/config/config.js
echo 'Sleep for 30 seconds to wait until documentserver reinitialize himself'
sleep 30
docker exec -it doc-linux sed -i '/"sessionidle": "0",/c\"sessionidle": "1h",' /etc/onlyoffice/documentserver/default.json
docker exec -it doc-linux supervisorctl restart all
docker cp archive-share-libs.sh doc-linux:/tmp/archive-share-libs.sh
docker exec -it doc-linux bash /tmp/archive-share-libs.sh
docker exec -it doc-linux dpkg-query --showformat='${Version}\n' --show onlyoffice-documentserver-ie
