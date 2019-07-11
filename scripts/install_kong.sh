#!/usr/bin/env bash

readonly LIMITS_CONFIG_FILE="/etc/security/limits.conf"


function config_limits() {
  if ! egrep -qi "^\s*#\s+Teko\s+Hardening" ${LIMITS_CONFIG_FILE}; then
    echo "" >> ${LIMITS_CONFIG_FILE}
    echo "# Teko Hardening" >> ${LIMITS_CONFIG_FILE}
  fi
  CHECKLIST=(
    "^\s*\*\s*soft\s*nproc|*    soft    nproc|^\s*\*\s*soft\s*nproc\s*65535\s*$|*       soft    nproc     65535"
    "^\s*\*\s*hard\s*nproc|*    hard    nproc|^\s*\*\s*hard\s*nproc\s*65535\s*$|*       hard    nproc     65535"
    "^\s*\*\s*soft\s*nofile|*    soft    nofile|^\s*\*\s*soft\s*nofile\s*65535\s*$|*       soft    nofile    65535"
    "^\s*\*\s*hard\s*nofile|*    hard    nofile|^\s*\*\s*hard\s*nofile\s*65535\s*$|*       hard    nofile    65535"
    "^\s*root\s*soft\s*nproc|root    soft    nproc|^\s*root\s*soft\s*nproc\s*65535\s*$|root    soft    nproc     65535"
    "^\s*root\s*hard\s*nproc|root    hard    nproc|^\s*root\s*hard\s*nproc\s*65535\s*$|root    hard    nproc     65535"
    "^\s*root\s*soft\s*nofile|root    soft    nofile|^\s*root\s*soft\s*nofile\s*65535\s*$|root    soft    nofile    65535"
    "^\s*root\s*hard\s*nofile|root    hard    nofile|^\s*root\s*hard\s*nofile\s*65535\s*$|root    hard    nofile    65535"
  )
  for ITEM in "${CHECKLIST[@]}"; do
    IFS='|' read -r PATTERN NAME PATTERN_CONFIG CONFIG <<< ${ITEM}
    if ! egrep -qi ${PATTERN} ${LIMITS_CONFIG_FILE}; then
      echo "${CONFIG}" >> ${LIMITS_CONFIG_FILE}
    else
      if ! egrep -qi ${PATTERN_CONFIG} ${LIMITS_CONFIG_FILE}; then
        sed -i "s/${PATTERN}/# ${NAME}/" ${LIMITS_CONFIG_FILE}
        echo "${CONFIG}" >> ${LIMITS_CONFIG_FILE}
      fi
    fi
  done
}

function prepare_env() {
  if [[ ! -d /var/log/kong ]]; then
    mkdir /var/log/kong
  fi
  touch -f /var/log/kong/proxy_access.log /var/log/kong/proxy_error.log
  touch -f /var/log/kong/admin_access.log /var/log/kong/admin_error.log
  chmod -R g-wx,o-rwx /var/log/kong/*

  cp ./templates/kong.conf.default kong.conf
  KONG_CONFIG_FILE="kong.conf"

  if [[ -n "${PROXY_SERVER_NAME}" ]]; then
    sed  -i "s/^\s*nginx_proxy_server_name\s*=.*$/nginx_proxy_server_name = ${PROXY_SERVER_NAME}/" ${KONG_CONFIG_FILE}
  fi

  if [[ -n "${PROXY_SSL_CERT}" ]]; then
    sed -i "s|^\s*#\s*ssl_cert\s*=.*$|ssl_cert = ${PROXY_SSL_CERT}|" ${KONG_CONFIG_FILE}
  fi

  if [[ -n "${PROXY_SSL_CERT_KEY}" ]]; then
    sed -i "s|^\s*#\s*ssl_cert_key\s*=.*$|ssl_cert_key = ${PROXY_SSL_CERT_KEY}|" ${KONG_CONFIG_FILE}
  fi

  if [[ -n "${ADMIN_SERVER_NAME}" ]]; then
    sed  -i "s/^\s*nginx_admin_server_name\s*=.*$/nginx_admin_server_name = ${ADMIN_SERVER_NAME}/" ${KONG_CONFIG_FILE}
  fi

  if [[ -n "${ADMIN_SSL_CERT}" ]]; then
    sed -i "s|^\s*#\s*admin_ssl_cert\s*=.*$|admin_ssl_cert = ${ADMIN_SSL_CERT}|" ${KONG_CONFIG_FILE}
  fi

  if [[ -n "${ADMIN_SSL_CERT_KEY}" ]]; then
    sed -i "s|^\s*#\s*admin_ssl_cert_key\s*=.*$|admin_ssl_cert_key = ${ADMIN_SSL_CERT_KEY}|" ${KONG_CONFIG_FILE}
  fi

  if [[ -n "${POSTGRESQL_HOST}" ]]; then
    sed -i "s/^\s*pg_host\s*=.*$/pg_host = ${POSTGRESQL_HOST}/" ${KONG_CONFIG_FILE}
  fi

  if [[ -n "${POSTGRESQL_PORT}" ]]; then
    sed -i "s/^\s*pg_port\s*=.*$/pg_port = ${POSTGRESQL_PORT}/" ${KONG_CONFIG_FILE}
  fi

  if [[ -n "${POSTGRESQL_USER}" ]]; then
    sed -i "s/^\s*pg_user\s*=.*$/pg_user = ${POSTGRESQL_USER}/" ${KONG_CONFIG_FILE}
  fi

  if [[ -n "${POSTGRESQL_PASSWORD}" ]]; then
    sed -i "s/^\s*#\s*pg_password\s*=.*$/pg_password = ${POSTGRESQL_PASSWORD}/" ${KONG_CONFIG_FILE}
  fi

  if [[ -n "${POSTGRESQL_DATABASE}" ]]; then
    sed -i "s/^\s*pg_database\s*=.*$/pg_database = ${POSTGRESQL_DATABASE}/" ${KONG_CONFIG_FILE}
  fi
}

function install_kong() {
  config_limits
  prepare_env

  apt-get install -y openssl libpcre3 procps perl
  dpkg -i ./packages/kong-1.2.1.*.deb

  mv kong.conf /etc/kong/kong.conf && chmod 644 /etc/kong/kong.conf
  cp ./templates/custom_nginx.template /etc/kong && chmod 644 /etc/kong/custom_nginx.template

  cp ./templates/kong.service /etc/systemd/system
  chmod 777 /etc/systemd/system/kong.service
  systemctl enable kong

  # bootstrap database
  /usr/local/bin/kong migrations bootstrap
  systemctl start kong
}

install_kong
