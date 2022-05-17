#!/bin/bash

oc project 3scale

ZYNC_QUE_POD=$(oc get pods -l threescale_component_element=zync-que | grep zync | awk '{print $1 }')

oc exec ${ZYNC_QUE_POD} cat /etc/pki/tls/cert.pem > certs/cert.pem

cat certs/sso-bundle-cert.pem >> certs/cert.pem

oc create configmap zync-que-ca-bundle --from-file=certs/cert.pem

oc set volume dc/zync-que \
    --add \
    --name=zync-que-ca-bundle \
    --mount-path /etc/pki/tls/cert.pem \
    --sub-path cert.pem \
    --source='{"configMap":{"name":"zync-que-ca-bundle","items":[{"key":"cert.pem","path":"cert.pem"}]}}'


oc patch dc/zync-que \
    --type=json \
    -p '[{"op": "add", "path": "/spec/template/spec/containers/0/volumeMounts/0/subPath", "value":"cert.pem"}]'   

oc get pods -w

ZYNC_QUE_POD=$(oc get pods -l threescale_component_element=zync-que | grep zync | awk '{print $1 }')
oc exec ${ZYNC_QUE_POD} -- cat /etc/pki/tls/zync/cert.pem
