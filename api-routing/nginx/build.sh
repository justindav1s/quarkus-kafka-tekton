#!/bin/bash

PROJECT=reverse-proxy

oc project $PROJECT

git add . && git commit -m"nginx reverse-proxy stuff" && git push

oc start-build microservices-on-openshift --follow

oc delete configmap reverse-proxy
oc create configmap reverse-proxy --from-file=reverse-proxy.conf=reverse-proxy.conf

oc rollout latest nginx