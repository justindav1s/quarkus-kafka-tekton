#!/bin/bash

rm -rf kafka-truststore.jks

oc get secret my-cluster2-cluster-ca-cert -n kafka-cluster2 -o jsonpath='{.data.ca\.crt}' | base64 --decode > ca.crt

PASSWORD=monkey123
keytool -import -trustcacerts -file ca.crt -keystore kafka-truststore.jks -storepass $PASSWORD -noprompt

rm -rf ca.crt
