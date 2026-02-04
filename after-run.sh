#!/usr/bin/env bash

# shellcheck source=/dev/null
source pluginsmaster.sh

USE_S3=$1
SERNAME=DocumentServer
PACKAGE_TYPE='onlyoffice-documentserver-ee'
JSON_EXE=/var/www/onlyoffice/documentserver/npm/json
DEFAULT_CONFIG=/etc/onlyoffice/documentserver/default.json

echo 'Wait for DocumentServer services to be ready'
wait_attempts=60
wait_delay=5
attempt=1
while [ "$attempt" -le "$wait_attempts" ]; do
    status_output=$(docker exec "$SERNAME" supervisorctl status 2>/dev/null || true)
    echo "Status output: $status_output"
    if [ -n "$status_output" ] && printf '%s\n' "$status_output" | awk '
        $1 == "ds:docservice" {doc=$2}
        $1 == "ds:converter" {conv=$2}
        END { exit !(doc=="RUNNING" && conv=="RUNNING") }
    '; then
        break
    fi
    sleep "$wait_delay"
    attempt=$((attempt + 1))
done
if [ "$attempt" -gt "$wait_attempts" ]; then
    echo 'Warning: DocumentServer services are not ready yet'
fi

# Preserve permissions/owner because json rewrites the file.
docker exec "$SERNAME" sh -c "
    config=\"$DEFAULT_CONFIG\"
    json=\"$JSON_EXE\"
    mode=\$(stat -c '%a' \"\$config\")
    owner=\$(stat -c '%u:%g' \"\$config\")
    \"\$json\" -f \"\$config\" -I -e 'this.services.CoAuthoring.autoAssembly.enable=true'
    \"\$json\" -f \"\$config\" -I -e 'this.services.CoAuthoring.expire.files=3600'
    \"\$json\" -f \"\$config\" -I -e 'this.services.CoAuthoring.editor.maxChangesSize=\"20mb\"'
    \"\$json\" -f \"\$config\" -I -e 'this.FileConverter.converter.errorfiles=\"error\"'
    chown \"\$owner\" \"\$config\"
    chmod \"\$mode\" \"\$config\"
"

docker exec "$SERNAME" sed -i 's/WARN/ALL/g' /etc/onlyoffice/documentserver/log4js/production.json
docker exec "$SERNAME" sed 's,autostart=false,autostart=true,' -i /etc/supervisor/conf.d/ds-example.conf
docker exec "$SERNAME" sed -i 's,access_log off,access_log /var/log/onlyoffice/documentserver/nginx.access.log,' /etc/onlyoffice/documentserver/nginx/includes/ds-common.conf
docker exec "$SERNAME" dpkg-query --showformat='${Version}\n' --show $PACKAGE_TYPE

if [ "${USE_S3}" == "true" ]; then
    python3 ./s3/s3_connector.py --name $SERNAME --no-restart
fi

docker exec "$SERNAME" supervisorctl restart all
