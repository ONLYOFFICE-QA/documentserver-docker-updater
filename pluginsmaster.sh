#!/usr/bin/env bash

SCRIPT=/usr/bin/documentserver-pluginsmanager.sh
ACTUAL_JSON=plugins-list-actual.json
SDKJS_PLUGINS=/var/www/onlyoffice/documentserver/sdkjs-plugins

_install_plugins() {
    SERNAME="$1"
    docker cp ./plugins/"$ACTUAL_JSON" "$SERNAME":"$SDKJS_PLUGINS"
    docker exec "$SERNAME" cat "$SDKJS_PLUGINS/$ACTUAL_JSON"
    docker exec "$SERNAME" $SCRIPT --install="$SDKJS_PLUGINS/$ACTUAL_JSON"
}
