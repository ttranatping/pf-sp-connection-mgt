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

curl -X POST \
  --header 'SOAPAction: getConnection' \
  --header 'Content-Type: text/plain' \
  --data "$bodyContent" \
  --user connectionmgt:$(prop 'serviceAuthentication_items_connectionManagement_connectionmgt_connectionmgt_sharedSecret') \
  https://localhost:9999/pf-mgmt-ws/ws/ConnectionMigrationMgr --insecure  | \
xpath '/soapenv:Envelope/soapenv:Body/getConnectionResponse/getConnectionReturn/text()' | \
sed "s/\&amp;/\&/;s/&lt;/\</;s/&lt;/\</;s/&gt;/\>/;s/&apos;/\'/" | \
xml ed -u "//urn:SigningKeyPairReference/@MD5Fingerprint" -v "\${SigningKeyPairMD5Reference}" | \
xml ed -u "//urn:DsigVerificationCert/urn:Base64EncodedCert" -v "\${DsigVerificationBase64EncodedCert}" | \
xml ed -u "//urn:SecondaryDsigVerificationCert/urn:Base64EncodedCert" -v "\${SecondaryDsigVerificationEncodedCert}" | \
xml ed -u "//urn:DecryptionKeyPairReference/@MD5Fingerprint" -v "\${DecryptionKeyPairMD5Reference}" | \
xml ed -u "//urn:SecondaryDecryptionKeyPairReference/@MD5Fingerprint" -v "\${SecondaryDecryptionKeyPairMD5Reference}" | \
xml ed -u "//urn:EncryptionCert/urn:Base64EncodedCert" -v "\${EncryptionEncodedCert}" | \
xml ed -u "//md:RoleDescriptor/urn:availableCert/urn:Base64EncodedCert" -v "\${RoleDescriptorEncodedCert}"

