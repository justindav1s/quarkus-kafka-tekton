#!/bin/bash

PROJECT=reverse-proxy

oc project ${PROJECT}

oc delete configmap default-conf
oc create configmap default-conf --from-file=default.conf=default.conf

oc rollout latest nginx

