
echo "Usage: ./get-md5-from-p12.sh <path-to-p12-file> <p12-password> <certificate-alias>"
echo "Hint: PKCS12 keystores exported from PingFederate has certificate-alias=ping"

java -jar ./pf-cert-extract-md5/target/pf-cert-extract-md5-0.0.1-SNAPSHOT-jar-with-dependencies.jar $1 $2 $3
