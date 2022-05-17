#!/bin/bash

PROJECT=load-generator

echo Deleting $PROJECT
oc delete project $PROJECT
echo Creating $PROJECT
oc new-project $PROJECT 2> /dev/null
while [ $? \> 0 ]; do
    sleep 1
    printf "."
oc new-project $PROJECT 2> /dev/null
done

oc create secret docker-registry rh-dockercfg \
  --docker-server=registry.redhat.io \
  --docker-username=${RHDN_USERNAME} \
  --docker-password=${RHDN_PASSWORD} \
  --docker-email=${RHDN_USERNAME} \
  -n $PROJECT

oc create secret docker-registry quayio-dockercfg \
  --docker-server=quay.io \
  --docker-username=${QUAYIO_USER} \
  --docker-password=${QUAYIO_PASSWORD} \
  --docker-email=${QUAYIO_EMAIL} \
  -n $PROJECT

oc secrets link builder rh-dockercfg
oc secrets link builder quayio-dockercfg

oc new-build https://github.com/justindav1s/microservices-on-openshift \
    --push-secret="quayio-dockercfg" \
    --to="quay.io/justindav1s/load-generator" \
    --context-dir="api-routing/load-generator" \
    --strategy="Docker" \
    --to-docker=true \
    --allow-missing-images


