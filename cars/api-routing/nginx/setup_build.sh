#!/bin/bash

PROJECT=reverse-proxy

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

oc create secret docker-registry datr-dockercfg \
  --docker-server=nexus3-docker-cicd.apps.ocp4.datr.eu \
  --docker-username=admin \
  --docker-password=monkey123 \
  --docker-email=admin@example.org \
  -n $PROJECT

oc create secret docker-registry nexus-dockercfg \
  --docker-server=nexus3-docker-cicd.apps.ocp4.datr.eu \
  --docker-username=${NEXUS_USER} \
  --docker-password=${NEXUS_PASSWORD} \
  --docker-email=docker@gmail.com \
  -n ${PROJECT}  


oc secrets link builder datr-dockercfg
oc secrets link builder rh-dockercfg
oc secrets link builder quayio-dockercfg
oc secrets link builder --for=pull datr-dockercfg

oc new-build registry.redhat.io/rhel8/nginx-116~https://github.com/justindav1s/microservices-on-openshift \
    --push-secret="datr-dockercfg" \
    --to="nexus3-docker-cicd.apps.ocp4.datr.eu/repository/docker/nginx/nginx-proxy:latest" \
    --context-dir="api-routing/nginx/src" \
    --strategy="Source" \
    --to-docker=true \
    --allow-missing-images


