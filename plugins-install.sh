#!/usr/bin/env bash

DS_PLUGINS_DIR='/var/www/onlyoffice/documentserver/sdkjs-plugins'
PLUGINS_REPO='sdkjs-plugins'
TMP_PLUGINS_DIR=/tmp/$PLUGINS_REPO
allowed_plugins=(example_controls)

apt-get -y update
apt-get -y install git
git clone -b master --depth 1 https://github.com/ONLYOFFICE/$PLUGINS_REPO/ $TMP_PLUGINS_DIR

for i in "${allowed_plugins[@]}"
do 
    cp -r --verbose $TMP_PLUGINS_DIR/"$i" $DS_PLUGINS_DIR
done
rm -rf $TMP_PLUGINS_DIR

own_repos_plugins=(plugin-html plugin-telegram plugin-wordscounter plugin-typograf plugin-rainbow)
for i in "${own_repos_plugins[@]}"
do 
    git clone -b master --depth 1 https://github.com/ONLYOFFICE/"$i" /tmp/"$i"
    cp -r --verbose /tmp/"$i" $DS_PLUGINS_DIR
    rm -rfv /tmp/"$i"
done

supervisorctl restart all
