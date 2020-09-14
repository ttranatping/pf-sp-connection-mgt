function prop {
    grep "${1}" ../docker-compose/pf.env|cut -d'=' -f2
}

entityId=$1
bodyContent="<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\">
    <soapenv:Header/>
      <soapenv:Body>
        <getConnection>
          <entityId>${entityId}</entityId>
          <role>SP</role>
        </getConnection>
      </soapenv:Body>
    </soapenv:Envelope>"

echo 'exporting connection = ' $1

SigningKeyPairMD5Reference_fingerprint=$(java -jar ./pf-cert-extract-md5/target/pf-cert-extract-md5-0.0.1-SNAPSHOT-jar-with-dependencies.jar ./example-certs/SigningKeyPairReference.p12 2FederateM0re ping)
DecryptionKeyPairMD5Reference_fingerprint=$(java -jar ./pf-cert-extract-md5/target/pf-cert-extract-md5-0.0.1-SNAPSHOT-jar-with-dependencies.jar ./example-certs/DecryptionKeyPairReference.p12 2FederateM0re ping)
SecondaryDecryptionKeyPairMD5Reference_fingerprint=$(java -jar ./pf-cert-extract-md5/target/pf-cert-extract-md5-0.0.1-SNAPSHOT-jar-with-dependencies.jar ./example-certs/SecondaryDecryptionKeyPairReference.p12 2FederateM0re ping)

DsigVerificationCert_Base64Encoded=$(cat ./example-certs/DsigVerificationCert.cer | base64)
SecondaryDsigVerificationCert_Base64EncodedCert=$(cat ./example-certs/SecondaryDsigVerificationCert.cer | base64)
EncryptionCert_Base64EncodedCert=$(cat ./example-certs/EncryptionCert.cer | base64)
RoleDescriptor_Base64EncodedCert=$(cat ./example-certs/RoleDescriptor.cer | base64)

curl -X POST \
  --header 'SOAPAction: getConnection' \
  --header 'Content-Type: text/plain' \
  --data "$bodyContent" \
  --user connectionmgt:$(prop 'serviceAuthentication_items_connectionManagement_connectionmgt_connectionmgt_sharedSecret') \
  https://localhost:9999/pf-mgmt-ws/ws/ConnectionMigrationMgr --insecure  | \
xpath '/soapenv:Envelope/soapenv:Body/getConnectionResponse/getConnectionReturn/text()' | \
sed "s/\&amp;/\&/;s/&lt;/\</;s/&lt;/\</;s/&gt;/\>/;s/&apos;/\'/" | \
xml ed -u "//urn:SigningKeyPairReference/@MD5Fingerprint" -v "${SigningKeyPairMD5Reference_fingerprint}" | \
xml ed -u "//urn:DsigVerificationCert/urn:Base64EncodedCert" -v "\${DsigVerificationCert_Base64Encoded}" | \
xml ed -u "//urn:SecondaryDsigVerificationCert/urn:Base64EncodedCert" -v "\${SecondaryDsigVerificationCert_Base64EncodedCert}" | \
xml ed -u "//urn:DecryptionKeyPairReference/@MD5Fingerprint" -v "\${DecryptionKeyPairMD5Reference_fingerprint}" | \
xml ed -u "//urn:SecondaryDecryptionKeyPairReference/@MD5Fingerprint" -v "\${SecondaryDecryptionKeyPairMD5Reference_fingerprint}" | \
xml ed -u "//urn:EncryptionCert/urn:Base64EncodedCert" -v "\${EncryptionCert_Base64EncodedCert}" | \
xml ed -u "//md:RoleDescriptor/urn:availableCert/urn:Base64EncodedCert" -v "\${RoleDescriptor_Base64EncodedCert}"

