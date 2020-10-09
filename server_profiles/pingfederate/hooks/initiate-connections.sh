mkdir -p /opt/out/instance/server/default/data

cd /opt/out/instance/server/default/data
rm -R connection-deployer
git clone ${CONNECTIONDEPLOYER_SERVER_PROFILE} connection-deployer

crontab ${HOOKS_DIR}/update-connections-crontab.txt

crond start
