#!/bin/bash

PROJECT=reverse-proxy

oc project ${PROJECT}

oc create secret docker-registry quayio-dockercfg \
  --docker-server=quay.io \
  --docker-username=${QUAYIO_USER} \
  --docker-password=${QUAYIO_PASSWORD} \
  --docker-email=${QUAYIO_EMAIL} \
  -n $PROJECT


oc apply -f dc.yaml


