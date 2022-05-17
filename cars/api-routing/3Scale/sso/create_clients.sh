#!/usr/bin/env bash

# This script requires jq, a command line to to parse and format JSon.
# https://stedolan.github.io/jq/

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
echo "Keycloak host : $KEYCLOAK"

NEW_CLIENT_SECRET="changeme"
NEW_CLIENT_NAME=3scale-test
NEW_CLIENT_REDIRECT_URI=http://127.0.0.1:9090/authcode

echo "GET ACCESS TONKEN FOR REGISTRATION CLIENT*****************************************"
# Get Access Token with Client Credentials Request
REALM="3Scale"
GRANT_TYPE="client_credentials"
CLIENT="3scale-client"
CLIENT_SECRET="3scale-client"

echo "Full URL : ${KEYCLOAK}/auth/realms/${REALM}/protocol/openid-connect/token"

#Get Token
POST_BODY="grant_type=${GRANT_TYPE}&client_id=${CLIENT}&client_secret=${CLIENT_SECRET}"
echo POST_BODY=${POST_BODY}

RESPONSE=$(curl -sk \
    -d ${POST_BODY} \
    -H "Content-Type: application/x-www-form-urlencoded" \
    ${KEYCLOAK}/auth/realms/${REALM}/protocol/openid-connect/token)

echo "RESPONSE"=${RESPONSE}
ACCESS_TOKEN=$(echo ${RESPONSE} | jq -r .access_token)
PART2_BASE64=$(echo ${ACCESS_TOKEN} | cut -d"." -f2)
PART2_BASE64=$(padBase64 ${PART2_BASE64})
echo ${PART2_BASE64} | base64 -D | jq .


# echo "CONSTRUCT JSON*******************************************************************"
# CLIENTJSON=`cat client_template.json`
# echo CLIENTJSON = ${CLIENTJSON}

# #update user's json representation with new consent id
# CLIENTJSON=$(echo ${CLIENTJSON} | jq  -r --arg CLIENT_NAME "$NEW_CLIENT_NAME" '.clientId = $CLIENT_NAME')
# echo CLIENTJSON = ${CLIENTJSON}

# CLIENTJSON=$(echo ${CLIENTJSON} | jq  -r --arg CLIENT_NAME "$NEW_CLIENT_NAME" '.name = $CLIENT_NAME')
# echo CLIENTJSON = ${CLIENTJSON}

# CLIENTJSON=$(echo ${CLIENTJSON} | jq  -r --arg CLIENT_SECRET "$NEW_CLIENT_SECRET" '.secret = $CLIENT_SECRET')
# echo CLIENTJSON = ${CLIENTJSON}

# CLIENTJSON=$(echo ${CLIENTJSON} | jq  -r --arg CLIENT_REDIRECT_URI "$NEW_CLIENT_REDIRECT_URI" '.redirectUris[0] = $CLIENT_REDIRECT_URI')
# echo CLIENTJSON = ${CLIENTJSON}

# echo ${CLIENTJSON} > ${NEW_CLIENT_NAME}.json


echo "REGISTER CLIENT IN accounts*******************************************************************"
REALM="3Scale"
RESPONSE=$(curl -vk \
    -X POST \
    --data @test-client.json \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    ${KEYCLOAK}/auth/admin/realms/${REALM}/clients)

echo "RESPONSE"=${RESPONSE}


#rm -rf ${NEW_CLIENT_NAME}.json