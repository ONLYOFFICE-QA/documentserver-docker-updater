#!/usr/bin/env bash

VERSION=$1
USE_S3=$2
if [ -z "${VERSION}" ]; then
    echo "VERSION is unset. Use 'latest' as docker version"
    VERSION=latest
fi
if [ "${USE_S3}" = "with-s3" ]; then
    USE_S3=true
else
    USE_S3=false
fi
echo "DS VERSION: ${VERSION}"
echo "CONNECT WITH S3: ${USE_S3}"

date_time=$(date +"%Y-%m-%d-%H-%M")
log_folder=/var/log/onlyoffice/documentserver/${date_time}/log
files_folder=/var/log/onlyoffice/documentserver/${date_time}/files
mkdir -pv "${log_folder}"
mkdir -pv "${files_folder}"
chmod -R 777 "${log_folder}"
chmod -R 777 "${files_folder}"
bash stop-service.sh
docker run -i -t -d -p 80:80 -p 443:443 --name DocumentServer \
 --restart=always \
 -v /usr/share/fonts:/usr/share/fonts/custom \
 -v /opt/onlyoffice/Data:/var/www/onlyoffice/Data \
 -v "${log_folder}":/var/log/onlyoffice/documentserver \
 -v "${files_folder}":/var/lib/onlyoffice/documentserver/App_Data/cache/files \
 -e JWT_ENABLED=true \
 -e JWT_SECRET=doc-linux \
 -e JWT_HEADER=AuthorizationJwt \
 -e WOPI_ENABLED=true \
 onlyoffice/4testing-documentserver-ee:"${VERSION}"

bash after-run.sh "${USE_S3}"
