#!/bin/bash

PROJECT=kafka-cluster2

oc get secret my-cluster2-cluster-ca-cert -n ${PROJECT} -o jsonpath='{.data.ca\.crt}' | base64 --decode > cluster-ca.crt
oc get secret my-cluster2-clients-ca -n ${PROJECT} -o jsonpath='{.data.ca\.key}' | base64 --decode > client-ca.key
oc get secret my-cluster2-clients-ca-cert -n ${PROJECT} -o jsonpath='{.data.ca\.crt}' | base64 --decode > client-ca.crt

