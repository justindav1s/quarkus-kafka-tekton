#!/bin/bash

function padBase64  {
    STR=$1
    MOD=$((${#STR}%4))
    if [ $MOD -eq 1 ]; then
       STR="${STR}="
    elif [ $MOD -gt 1 ]; then
       STR="${STR}=="
    fi
    echo ${STR}
}


KEYCLOAK=https://keycloak-sso.apps.sno.openshiftlabs.net
REALM="3Scale"
GRANT_TYPE="password"
# CLIENT="ac04a7b1"
# CLIENT_SECRET="98b6f034c7e7a36e18d5ac058d8760eb"
CLIENT="7734ebd0"
CLIENT_SECRET="65d7b4812e347b304fac877019d1ef7f"
USER="justin"
USER_PASSWORD="password"

#echo "Keycloak host : $KEYCLOAK"


#Get Token
POST_BODY="grant_type=${GRANT_TYPE}&client_id=${CLIENT}&client_secret=${CLIENT_SECRET}&username=${USER}&password=${USER_PASSWORD}"

#echo "Keycloak host : $KEYCLOAK"
#echo POST_BODY=${POST_BODY}

RESPONSE=$(curl -sk \
    -d ${POST_BODY} \
    -H "Content-Type: application/x-www-form-urlencoded" \
    ${KEYCLOAK}/auth/realms/${REALM}/protocol/openid-connect/token)

echo "RESPONSE"=${RESPONSE}
ACCESS_TOKEN=$(echo ${RESPONSE} | jq -r .access_token)
PART2_BASE64=$(echo ${ACCESS_TOKEN} | cut -d"." -f2)
PART2_BASE64=$(padBase64 ${PART2_BASE64})
echo "ACCESS TOKEN"
echo ${PART2_BASE64} | base64 -D | jq .

curl -vk \
    -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -H "X-3scale-proxy-secret-token: Shared_secret_sent_from_proxy_to_API_backend_dd585619e2c4c67a" \
    "https://sso-product-staging-3scale.apps.sno.openshiftlabs.net:443/products/all"



