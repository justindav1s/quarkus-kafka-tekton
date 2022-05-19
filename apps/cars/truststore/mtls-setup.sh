#!/bin/bash

oc get secret mtls-user -n kafka-cluster2 -o jsonpath='{.data.user\.p12}' | base64 --decode > user.p12
oc get secret mtls-user -n kafka-cluster2 -o jsonpath='{.data.user\.password}' | base64 --decode > user.password

export PASSWORD=`cat user.password`
echo PASSWORD: $PASSWORD

keytool -importkeystore \
    -srckeystore user.p12 -srcstoretype pkcs12 -srcstorepass $PASSWORD \
    -destkeystore mtls-user-keystore.jks -deststoretype jks -deststorepass $PASSWORD

rm -rf user.p12 user.password
