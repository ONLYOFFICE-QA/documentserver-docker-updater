#!/usr/bin/env bash
date_time=$(date +"%Y-%m-%d-%H-%M")
log_folder=/var/log/onlyoffice/documentserver/${date_time}/log
files_folder=/var/log/onlyoffice/documentserver/${date_time}/files
mkdir -pv ${log_folder}
mkdir -pv ${files_folder}
chmod -R 777 ${log_folder}
chmod -R 777 ${files_folder}
docker exec -it doc-linux bash -c "documentserver-prepare4shutdown.sh"
docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)
docker rmi $(docker images -q)
docker volume rm $(docker volume ls -qf dangling=true)
docker run -i -t -d -p 80:80 -p 443:443 --name doc-linux \
 -v /usr/share/fonts:/usr/share/fonts/custom \
 -v /opt/onlyoffice/Data:/var/www/onlyoffice/Data \
 -v ${log_folder}:/var/log/onlyoffice/documentserver \
 -v ${files_folder}:/var/lib/onlyoffice/documentserver/App_Data/cache/files/error \
 onlyoffice/4testing-documentserver-integration:4.3.6.2
docker cp ~/local.json doc-linux:/etc/onlyoffice/documentserver/local.json
docker cp ~/config.js doc-linux:/var/www/onlyoffice/documentserver/server/Metrics/config/config.js
echo 'Sleep for 30 seconds to wait until documentserver reinitialize himself'
sleep 30
docker exec -it doc-linux sed -i '/"sessionidle": "0",/c\"sessionidle": "1h",' /etc/onlyoffice/documentserver/default.json
docker exec -it doc-linux supervisorctl restart all
docker exec -it doc-linux dpkg-query --showformat='${Version}\n' --show onlyoffice-documentserver-integration