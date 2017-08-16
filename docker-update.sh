#!/usr/bin/env bash
date_time=$(date +"%Y-%m-%d-%H-%M")
log_folder=/var/log/onlyoffice/documentserver/${date_time}/log
files_folder=/var/log/onlyoffice/documentserver/${date_time}/files
mkdir -pv ${log_folder}
mkdir -pv ${files_folder}
chmod -R 777 ${log_folder}
chmod -R 777 ${files_folder}
bash stop-service.sh
docker run -i -t -d -p 80:80 -p 443:443 --name doc-linux \
 -v /usr/share/fonts:/usr/share/fonts/custom \
 -v /opt/onlyoffice/Data:/var/www/onlyoffice/Data \
 -v ${log_folder}:/var/log/onlyoffice/documentserver \
 -v ${files_folder}:/var/lib/onlyoffice/documentserver/App_Data/cache/files/error \
 onlyoffice/4testing-documentserver-integration:latest
bash after-run.sh