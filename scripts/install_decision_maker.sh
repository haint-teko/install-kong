#!/usr/bin/env bash
# install decision-maker plugin

PLUGIN_NAME="decision-maker"
KONG_CONFIG_FILE="/etc/kong/kong.conf"

cd ./plugins/decision-maker
luarocks make > /dev/null 2>&1
luarocks make
cd ../..

PLUGINS=$(egrep "^\s*plugins" ${KONG_CONFIG_FILE})
sed -i "s|^\s*plugins\s*=\s*.*$|${PLUGINS}, ${PLUGIN_NAME}|" ${KONG_CONFIG_FILE}
systemctl restart kong

/usr/local/bin/kong migrations up --conf ${KONG_CONFIG_FILE}