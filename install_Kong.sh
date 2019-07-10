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

function install_kong() {
  apt-get install -y openssl libpcre3 procps perl

}

