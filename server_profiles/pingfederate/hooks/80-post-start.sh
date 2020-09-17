#!/usr/bin/env sh
#
# Ping Identity DevOps - Docker Build Hooks
#
#- This script is used to import any configurations that are
#- needed after PingAccess starts

# shellcheck source=../../../../pingcommon/opt/staging/hooks/pingcommon.lib.sh
. "${HOOKS_DIR}/pingcommon.lib.sh"

if test "${OPERATIONAL_MODE}" = "CLUSTERED_CONSOLE"  || test "${OPERATIONAL_MODE}" = "CLUSTERED_DUAL" || test "${OPERATIONAL_MODE}" = "STANDALONE"
then
    echo "INFO: waiting for PingFederate to start before importing configuration"
    wait-for 127.0.0.1:9999 -t 200 -- echo PingFederate is up

    ${HOOKS_DIR}/call-apis.sh
    
    if test "${OPERATIONAL_MODE}" = "CLUSTERED_CONSOLE"
    then
      curl -X POST --basic -u Administrator:2FederateM0re --header 'Content-Type: application/json' --header 'X-XSRF-Header: PingFederate' https://localhost:9999/pf-admin-api/v1/cluster/replicate --insecure
    fi

    test ${?} -ne 0 && kill 1
fi

if test "${OPERATIONAL_MODE}" = "CLUSTERED_ENGINE"
then
    echo "INFO: Configuring engine node - Engine nodes should receive config from the cluster"
fi

echo "INFO: Initiating connection management"
${HOOKS_DIR}/initiate-connections.sh

if test "${OPERATIONAL_MODE}" = "CLUSTERED_CONSOLE"
then
    echo "Bringing eth0 back up..."
    ip link set eth0 up
fi
