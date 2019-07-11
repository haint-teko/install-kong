#!/usr/bin/env bash
# install decision-maker plugin

PLUGIN_NAME="decision-maker"

cd ./plugins/decision-maker
luarocks make > /dev/null 2>&1
luarocks make
cd ../..

PLUGINS=$(egrep "^\s*plugins" /etc/kong/kong.conf)
sed -i "s|^\s*plugins\s*=\s*.*$|${PLUGINS}, ${PLUGIN_NAME}"
systemctl reload kong

/usr/local/bin/kong migrations bootstrap up --conf /etc/kong/kong.conf
