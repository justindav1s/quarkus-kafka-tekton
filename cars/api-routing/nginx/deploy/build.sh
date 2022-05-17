#!/bin/bash

oc project cd-improvements

oc delete bc nginx-proxy
oc delete secret jd-bitbucket

oc create secret generic jd-bitbucket \
    --from-literal=username=${MO_BITBUCKET_USER} \
    --from-literal=password=${MO_BITBUCKET_PASS} \
    --type=kubernetes.io/basic-auth
  
oc new-build openshift/nginx:1.12~https://bitbucket.org/motabilityoperations/nginx-proxy.git \
    --name='nginx-proxy' \
    --source-secret='jd-bitbucket' \
    --context-dir="src" \
    --strategy="Source" \
    --allow-missing-images
