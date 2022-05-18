#!/bin/bash

PROJECT_ROOT=../..

. ${PROJECT_ROOT}/env.sh

APP=cars
APP_DEPLOY_NAME=${APP}-serverless
PROFILE=dev

oc project $DEPLOY_PROJECT

oc delete secret -l app=${APP_DEPLOY_NAME}  -n ${DEPLOY_PROJECT}
oc delete kservice -l app=${APP_DEPLOY_NAME} -n ${DEPLOY_PROJECT}

oc create secret generic ${APP_DEPLOY_NAME}-${PROFILE}-application-properties \
    --from-file=application.properties=${PROJECT_ROOT}/${APPS_DIR}/${APP}/src/main/resources/application.${PROFILE}.properties \
    -n ${DEPLOY_PROJECT}

oc create secret generic ${APP_DEPLOY_NAME}-${PROFILE}-kafka-truststore \
    --from-file=${PROJECT_ROOT}/${APPS_DIR}/${APP}/truststore/kafka-truststore.jks \
    -n ${DEPLOY_PROJECT}

oc label secret ${APP_DEPLOY_NAME}-${PROFILE}-application-properties app=${APP_DEPLOY_NAME} -n ${DEPLOY_PROJECT}
oc label secret ${APP_DEPLOY_NAME}-${PROFILE}-kafka-truststore app=${APP_DEPLOY_NAME} -n ${DEPLOY_PROJECT}

oc apply -f knative-serving-template.yaml