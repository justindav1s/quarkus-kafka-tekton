#!/bin/bash


oc project 3scale


oc delete DeveloperAccount jdcorp-dev-acc-1
oc delete DeveloperUser justin
oc delete secret justin-creds-secret
oc delete product amazin-api-product 
oc delete backend amazin-api-inventory-backend
oc delete OpenAPI product-openapi

sleep 30

oc create secret generic justin-creds-secret --from-literal=password=password
oc apply -f user.yaml
oc apply -f account.yaml
oc apply -f open-api.yaml