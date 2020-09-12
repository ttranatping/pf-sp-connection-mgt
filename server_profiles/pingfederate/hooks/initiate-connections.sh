cd /opt/out/instance/server/default/data
rm -R connection-deployer
git clone ${CONNECTIONDEPLOYER_SERVER_PROFILE} connection-deployer

cp ${HOOKS_DIR}/update-connections.sh /etc/periodic/15min
