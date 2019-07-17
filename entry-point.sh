#!/bin/sh
set -e

export KONG_NGINX_DAEMON=off

if [[ "$1" == "kong" ]]; then
  PREFIX=${KONG_PREFIX:=/usr/local/kong}
  mkdir -p ${PREFIX}

  if [[ "$2" == "start" ]]; then
    shift 2
    kong prepare -p ${PREFIX} "$@"

    exec /usr/local/openresty/nginx/sbin/nginx \
      --prefix ${PREFIX} \
      --conf /etc/kong/nginx.conf \
      --nginx-conf /etc/kong/custom_nginx.template
  fi
fi

exec "$@"