#!/usr/bin/env bash

DS_PLUGINS_DIR='/var/www/onlyoffice/documentserver/sdkjs-plugins'
PLUGINS_REPO='sdkjs-plugins'
TMP_PLUGINS_DIR=/tmp/$PLUGINS_REPO
allowed_plugins=(example_work_with_content_controls helloworld)


apt-get -y update
apt-get -y install git
git clone -b develop --depth 1 https://github.com/ONLYOFFICE/$PLUGINS_REPO/ $TMP_PLUGINS_DIR

for i in "${allowed_plugins[@]}"
do 
    cp -r --verbose $TMP_PLUGINS_DIR/"$i" $DS_PLUGINS_DIR
done
rm -rf $TMP_PLUGINS_DIR
