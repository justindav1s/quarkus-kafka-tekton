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
GRANT_TYPE="authorization_code"
CLIENT="7734ebd0"
CLIENT_SECRET="65d7b4812e347b304fac877019d1ef7f"
USER="justin"
USER_PASSWORD="password"

echo "Keycloak host : $KEYCLOAK"

#Get Code
GET_BODY="scope=openid&response_type=code&client_id=${CLIENT}&redirect_uri=http://127.0.0.1:9090/getcode"

RESPONSE=$(curl -vk -D headers.txt \
    -u ${USER}:${USER_PASSWORD} \
    -X GET \
    "${KEYCLOAK}/auth/realms/${REALM}/protocol/openid-connect/auth?${GET_BODY}")

echo RESPONSE=$RESPONSE
LOC=$(grep location headers.txt)
#rm -rf headers.txt
CODE=`echo ${LOC} | awk -F'[=&]' '{print $4}' | tr -cd "[:print:]\n"`

echo "CODE"=${CODE}
echo ${#CODE}

#Get Token
POST_BODY="grant_type=${GRANT_TYPE}&redirect_uri=http://127.0.0.1:9090/getcode&client_id=${CLIENT}&client_secret=${CLIENT_SECRET}&code="
POST_BODY=${POST_BODY}${CODE}
echo POST_BODY=${POST_BODY}

RESPONSE=$(curl -vk \
    -d ${POST_BODY} \
    -H "Content-Type: application/x-www-form-urlencoded" \
    ${KEYCLOAK}/auth/realms/${REALM}/protocol/openid-connect/token)

echo "RESPONSE"=${RESPONSE}
ACCESS_TOKEN=$(echo ${RESPONSE} | jq -r .access_token)
PART2_BASE64=$(echo ${ACCESS_TOKEN} | cut -d"." -f2)
PART2_BASE64=$(padBase64 ${PART2_BASE64})
echo "ACCESS TOKEN"
echo ${PART2_BASE64} | base64 -D | jq .

# echo
# ACCESS_TOKEN=$(echo ${RESPONSE} | jq -r .refresh_token)
# PART2_BASE64=$(echo ${ACCESS_TOKEN} | cut -d"." -f2)
# PART2_BASE64=$(padBase64 ${PART2_BASE64})
# echo "REFRESH TOKEN"
# echo ${PART2_BASE64} | base64 -D | jq .

# echo
# ACCESS_TOKEN=$(echo ${RESPONSE} | jq -r .id_token)
# PART2_BASE64=$(echo ${ACCESS_TOKEN} | cut -d"." -f2)
# PART2_BASE64=$(padBase64 ${PART2_BASE64})
# echo "ID TOKEN"
# echo ${PART2_BASE64} | base64 -D | jq .

# curl -vk \
#     -H "Authorization: Bearer ${ACCESS_TOKEN}" \
#     -H "X-3scale-proxy-secret-token: Shared_secret_sent_from_proxy_to_API_backend_dd585619e2c4c67a" \
#     "https://sso-product-staging-3scale.apps.sno.openshiftlabs.net:443/products/all"