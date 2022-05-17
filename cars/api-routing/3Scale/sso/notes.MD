## Docs

https://access.redhat.com/documentation/en-us/red_hat_3scale_api_management/2.11/html/administering_the_api_gateway/openid-connect
https://access.redhat.com/documentation/en-us/red_hat_3scale_api_management/2.11/html/administering_the_api_gateway/openid-connect#integration-threescale-rhsso_api-gateway-apicast

https://medium.com/@tamber/api-management-security-series-3scale-oidc-using-rh-sso-demo-643feb1e1c0d



## Configure trust between zync-que and sso

echo -n | openssl s_client \
    -connect keycloak-sso.apps.sno.openshiftlabs.net:443 \
    -servername keycloak-sso.apps.sno.openshiftlabs.net \
    --showcerts \
    | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' \
    > customCA.pem

curl -v https://keycloak-sso.apps.sno.openshiftlabs.net/auth/realms/master --cacert customCA.pem 

ZYNCQUEPOD=$(oc get pods --field-selector=status.phase=Running -n 3scale | grep zync-que | awk '{print $1 }')

oc exec ${ZYNCQUEPOD} -- cat /etc/pki/tls/cert.pem > zync.pem

cat customCA.pem >> zync.pem

oc create configmap zync-ca-bundle --from-file=./zync.pem

oc set volume dc/zync-que \
    --add \
    --name=zync-ca-bundle \
    --mount-path /etc/pki/tls/zync/zync.pem \
    --sub-path zync.pem \
    --source='{"configMap":{"name":"zync-ca-bundle","items":[{"key":"zync.pem","path":"zync.pem"}]}}'


## Setting up keycloak

1. Install the operator
2. oc apply -f keycloak-cluster.yaml -n sso
3. oc apply -f 3scale-realm.yaml -n sso
4. oc apply -f 3scale-client.yaml -n sso

Set the service account roles for the client:

Navigate to the Service Account Roles tab of the client.
In the Client Roles dropdown list, click realm-management.
In the Available Roles pane, select the manage-clients list item and assign the role by clicking Add selected >>.

5. oc apply -f 3scale-user.yaml -n sso


Find £cale product > settings > Authentication

 OpenID Connect Use OpenID Connect for any OAuth 2.0 flow.

OpenID Connect Issuer
https://sso.example.com/auth/realms/gateway
 Location of your OpenID Provider. The format of this endpoint is determined on your OpenID Provider setup. A common guidance would be "https://<CLIENT_ID>:<CLIENT_SECRET>@<HOST>:<PORT>/auth/realms/<REALM_NAME>". 

https://3scale-client:3scale-client@keycloak-sso.apps.sno.openshiftlabs.net:443/auth/realms/3Scale 

bRgg6z-WqkRmXQ==