#!/bin/bash

. ../env.sh

HTTP_CONTEXT=cars
APP_DIR=${APPS_DIR}/${HTTP_CONTEXT}
APP=cars-serverless
PROFILE=dev

oc project ${CICD_PROJECT}

oc delete configmap ${APP}-${PROFILE}-application-properties ${APP}-${PROFILE}-kafka-truststore -n ${CICD_PROJECT}

oc create configmap ${APP}-${PROFILE}-application-properties \
    --from-file=application.properties=../${APP_DIR}/config/application.${PROFILE}.properties \
    -n ${CICD_PROJECT}

oc create configmap ${APP}-${PROFILE}-kafka-truststore \
    --from-file=../${APP_DIR}/truststore/kafka-truststore.jks \
    -n ${CICD_PROJECT}

oc label configmap ${APP}-${PROFILE}-application-properties app=${APP} -n ${CICD_PROJECT}
oc label configmap ${APP}-${PROFILE}-kafka-truststore app=${APP} -n ${CICD_PROJECT}

cat << EOF > ${APP}-${PROFILE}-deploy-knative-pipeline-pvc.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: ${APP}-${PROFILE}-pipeline-pvc
  labels:
      app: ${APP}
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 500Mi
EOF

oc apply -f tasks/run-script-task.yaml
oc apply -f tasks/oc-knative-deploy-template.yaml
oc apply -f pipelines/quarkus-knative-deploy.yaml

oc delete PipelineRun -l tekton.dev/pipeline=quarkus-knative-deploy

tkn pipeline start quarkus-knative-deploy \
    -w name=shared-workspace,volumeClaimTemplateFile=${APP}-${PROFILE}-deploy-knative-pipeline-pvc.yaml \
    -w name=truststore,config=${APP}-${PROFILE}-kafka-truststore \
    -w name=application-properties,config=${APP}-${PROFILE}-application-properties \
    -p APP_NAME=${APP} \
    -p APP_DIR=${APP_DIR} \
    -p HTTP_CONTEXT=${HTTP_CONTEXT} \
    -p DEPLOY_PROJECT=${DEPLOY_PROJECT} \
    -p GIT_REPO=https://github.com/justindav1s/quarkus-kafka-tekton.git \
    -p GIT_BRANCH=main \
    -p APP_PROFILE=${PROFILE} \
    -p IMAGE_NAME=cars-native \
    -p IMAGE_REPO=${QUAYIO_HOST}/${QUAYIO_USER} \
    -p CONTAINER_WORKING_DIR=work \
    --use-param-defaults \
    --showlog \
     -n ${CICD_PROJECT}
