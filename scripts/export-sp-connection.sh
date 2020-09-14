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
echo 'substituting with certificate version = ' $2


curl -X POST \
  --header 'SOAPAction: getConnection' \
  --header 'Content-Type: text/plain' \
  --data "$bodyContent" \
  --user connectionmgt:$(prop 'serviceAuthentication_items_connectionManagement_connectionmgt_connectionmgt_sharedSecret') \
  https://localhost:9999/pf-mgmt-ws/ws/ConnectionMigrationMgr --insecure  | \
xpath '/soapenv:Envelope/soapenv:Body/getConnectionResponse/getConnectionReturn/text()' | \
sed "s/\&amp;/\&/;s/&lt;/\</;s/&lt;/\</;s/&gt;/\>/;s/&apos;/\'/" | \
xml ed -u "//urn:SigningKeyPairReference/@MD5Fingerprint" -v "\${SigningKeyPairMD5Reference_$2}" | \
xml ed -u "//urn:DsigVerificationCert/urn:Base64EncodedCert" -v "\${DsigVerificationBase64EncodedCert_$2}" | \
xml ed -u "//urn:SecondaryDsigVerificationCert/urn:Base64EncodedCert" -v "\${SecondaryDsigVerificationEncodedCert_$2}" | \
xml ed -u "//urn:DecryptionKeyPairReference/@MD5Fingerprint" -v "\${DecryptionKeyPairMD5Reference_$2}" | \
xml ed -u "//urn:SecondaryDecryptionKeyPairReference/@MD5Fingerprint" -v "\${SecondaryDecryptionKeyPairMD5Reference_$2}" | \
xml ed -u "//urn:EncryptionCert/urn:Base64EncodedCert" -v "\${EncryptionEncodedCert_$2}" | \
xml ed -u "//md:RoleDescriptor/urn:availableCert/urn:Base64EncodedCert" -v "\${RoleDescriptorEncodedCert_$2}"

