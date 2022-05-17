#!/bin/bash

SSO_HOST=keycloak-sso.apps.sno.openshiftlabs.net
rm -rf certs

mkdir certs

oc extract secret/sso-x509-https-secret --keys=tls.crt -n sso --to=certs

cat certs/tls.crt | sed '/-----END CERTIFICATE-----/q' | openssl x509 -subject -issuer -noout

cp certs/tls.crt certs/sso-bundle-cert.pem

echo | openssl s_client -showcerts \
    -servername ${SSO_HOST} \
    -connect ${SSO_HOST}:443 2>/dev/null \
    | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > certs/sso_route_cert.pem

cat certs/sso_route_cert.pem >> certs/sso-bundle-cert.pem

SSL_CERT_FILE=certs/sso-bundle-cert.pem curl -v https://${SSO_HOST}