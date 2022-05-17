#!/bin/bash

oc project 3scale

ZYNC_POD=$(oc get pods -l threescale_component_element=zync | grep zync | awk '{print $1 }')

oc exec ${ZYNC_POD} cat /etc/pki/tls/cert.pem > certs/zync.pem

cat certs/sso-bundle-cert.pem >> certs/zync.pem

oc create configmap zync-ca-bundle --from-file=certs/zync.pem

oc set volume dc/zync \
    --add \
    --name=zync-ca-bundle \
    --mount-path /etc/pki/tls/zync/zync.pem \
    --sub-path zync.pem \
    --source='{"configMap":{"name":"zync-ca-bundle","items":[{"key":"zync.pem","path":"zync.pem"}]}}'

oc patch dc/zync \
    --type=json \
    -p '[{"op": "add", "path": "/spec/template/spec/containers/0/volumeMounts/0/subPath", "value":"zync.pem"}]'    

oc get pods -w

ZYNC_POD=$(oc get pods -l threescale_component_element=zync | grep zync | awk '{print $1 }')
oc exec ${ZYNC_POD} -- cat /etc/pki/tls/zync/zync.pem

oc set env dc/zync SSL_CERT_FILE=/etc/pki/tls/zync/zync.pem
