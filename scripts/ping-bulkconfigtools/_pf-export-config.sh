function prop {
    grep "${1}" ../../docker-compose/common.env|cut -d'=' -f2
}

echo "Creating output folder..."
mkdir out

echo "Downloading config from https://localhost:9999..."
curl -X GET --basic -u Administrator:$(prop 'PING_IDENTITY_PASSWORD') --header 'Content-Type: application/json' --header 'X-XSRF-Header: PingFederate' https://localhost:9999/pf-admin-api/v1/bulk/export --insecure > out/pf-export.json

echo "Creating/modifying docker-compose/pf.env and server_profiles/pingfederate/instance/server/default/drop-in-config/003-importbulkconfig/requestBody.json.subst..."
java -jar ping-bulkexport-tools-project/target/ping-bulkexport-tools-0.0.1-SNAPSHOT-jar-with-dependencies.jar ./ping-bulkexport-tools-project/in/pf-config.json ./out/pf-export.json ../../docker-compose/pf.env ../../server_profiles/pingfederate/instance/server/default/drop-in-config/003-importbulkconfig/requestBody.json.subst > out/pf-export-convert.log

echo "Creating/modifying k8/02-completeinstall/pf.env and server_profiles/pingfederate/instance/server/default/drop-in-config/003-importbulkconfig/requestBody.json.subst..."
java -jar ping-bulkexport-tools-project/target/ping-bulkexport-tools-0.0.1-SNAPSHOT-jar-with-dependencies.jar ./ping-bulkexport-tools-project/in/pf-config.json ./out/pf-export.json ../../k8/02-completeinstall/pf.env ../../server_profiles/pingfederate/instance/server/default/drop-in-config/003-importbulkconfig/requestBody.json.subst > out/pf-k8-export-convert.log

