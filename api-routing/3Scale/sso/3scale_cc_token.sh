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
GRANT_TYPE="client_credentials"
CLIENT="3scale-client"
CLIENT_SECRET="a46c4825-c3e2-46ad-ba19-373170a25acc"

echo "Keycloak host : $KEYCLOAK"

#Get Token
POST_BODY="scope=openid&grant_type=${GRANT_TYPE}&client_id=${CLIENT}&client_secret=${CLIENT_SECRET}"

echo "Keycloak host : $KEYCLOAK"
echo POST_BODY=${POST_BODY}

RESPONSE=$(curl -vk \
    -d ${POST_BODY} \
    -H "Content-Type: application/x-www-form-urlencoded" \
    ${KEYCLOAK}/auth/realms/${REALM}/protocol/openid-connect/token)

echo "RESPONSE"=${RESPONSE}
echo "ACCESS TOKEN"
ACCESS_TOKEN=$(echo ${RESPONSE} | jq -r .access_token)
PART2_BASE64=$(echo ${ACCESS_TOKEN} | cut -d"." -f2)
PART2_BASE64=$(padBase64 ${PART2_BASE64})
echo ${PART2_BASE64} | base64 -D | jq .

echo "REFRESH TOKEN"
REFRESH_TOKEN=$(echo ${RESPONSE} | jq -r .refresh_token)
PART2_BASE64=$(echo ${REFRESH_TOKEN} | cut -d"." -f2)
PART2_BASE64=$(padBase64 ${PART2_BASE64})
echo ${PART2_BASE64} | base64 -D | jq .

echo "ID TOKEN"
REFRESH_TOKEN=$(echo ${RESPONSE} | jq -r .id_token)
PART2_BASE64=$(echo ${REFRESH_TOKEN} | cut -d"." -f2)
PART2_BASE64=$(padBase64 ${PART2_BASE64})
echo ${PART2_BASE64} | base64 -D | jq .
