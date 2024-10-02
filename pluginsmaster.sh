#!/usr/bin/env bash

SCRIPT=/usr/bin/documentserver-pluginsmanager.sh
ACTUAL_JSON=plugins-list-actual.json
SDKJS_PLUGINS=/var/www/onlyoffice/documentserver/sdkjs-plugins

_install_plugins() {
    SERNAME="$1"
    docker cp ./plugins/"$ACTUAL_JSON" "$SERNAME":"$TOOLS_DIR"
    docker exec "$SERNAME" cat "$TOOLS_DIR/$ACTUAL_JSON"
    docker exec "$SERNAME" $SCRIPT --install="$SDKJS_PLUGINS/$ACTUAL_JSON"
}
