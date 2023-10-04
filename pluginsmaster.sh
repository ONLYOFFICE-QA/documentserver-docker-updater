#!/usr/bin/env bash

TOOLS_DIR=/var/www/onlyoffice/documentserver/server/tools
SDKJS_PLUGINS_DIR=/var/www/onlyoffice/documentserver/sdkjs-plugins
PM=pluginsmanager
ACTUAL_JSON=plugins-list-actual.json

_install_plugins() {
    SERNAME="$1"
    docker cp ./plugins/"$ACTUAL_JSON" "$SERNAME":"$TOOLS_DIR"
    docker exec "$SERNAME" cat "$TOOLS_DIR/$ACTUAL_JSON"
    docker exec "$SERNAME" ./"$TOOLS_DIR/$PM" \
                --directory="$SDKJS_PLUGINS_DIR" \
                --install="$TOOLS_DIR/$ACTUAL_JSON"
    docker exec "$SERNAME" supervisorctl restart ds:docservice
}
