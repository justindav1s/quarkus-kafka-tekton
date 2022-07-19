#!/bin/bash

. ../../../../../env.sh

.  ../../env.sh

oc login https://${IP} -u $USER

oc project ${PROJECT}

oc delete all -l app=${APP} -l app=${APP}-native --ignore-not-found=true -n ${PROJECT}
oc delete pvc -l app=${APP} -l app=${APP}-native --ignore-not-found=true -n ${PROJECT}
oc delete sa ${APP}-sa --ignore-not-found=true -n ${PROJECT}
oc delete is,bc,dc,svc,route,sa ${APP} --ignore-not-found=true -n ${PROJECT}
oc delete is,bc,dc,svc,route,sa ${APP}-native --ignore-not-found=true -n ${PROJECT}
oc delete configmap ${APP}-config --ignore-not-found=true -n ${PROJECT}

echo Setting up ${APP} for ${PROJECT}
oc new-app -f microservice-dev-quay-template.yaml \
    -p PROJECT=${PROJECT} \
    -p APPLICATION_NAME=${APP} \
    -p BASE_IMAGE_NAMESPACE="openshift" \
    -p BASE_IMAGE=${S2I_IMAGE} \
    -n ${PROJECT}

oc secrets link default quayio-dockercfg --for=pull -n ${PROJECT}
oc secrets link ${APP}-sa quayio-dockercfg --for=pull -n ${PROJECT}