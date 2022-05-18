#!/bin/bash

. ../env.sh

APP=cars
PROFILE=dev
APP_DIR=${APPS_DIR}/${APP}
HTTP_CONTEXT=cars

oc project ${CICD_PROJECT}

oc delete configmap ${APP}-${PROFILE}-application-properties ${APP}-${PROFILE}-kafka-truststore -n ${CICD_PROJECT}

oc create configmap ${APP}-${PROFILE}-application-properties \
    --from-file=application.properies=../${APP_DIR}/config/application.${PROFILE}.properties \
    -n ${CICD_PROJECT}

oc create configmap ${APP}-${PROFILE}-kafka-truststore \
    --from-file=../${APP_DIR}/truststore/kafka-truststore.jks \
    -n ${CICD_PROJECT}

oc label configmap ${APP}-${PROFILE}-application-properties app=${APP} -n ${CICD_PROJECT}
oc label configmap ${APP}-${PROFILE}-kafka-truststore app=${APP} -n ${CICD_PROJECT}

cat << EOF > ${APP}-${PROFILE}-pipeline-pvc.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: ${APP}-${PROFILE}-pipeline-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 500Mi
EOF

oc apply -f tasks/run-script-task.yaml -n ${CICD_PROJECT}
oc apply -f tasks/oc-deploy-template.yaml -n ${CICD_PROJECT}
oc apply -f pipelines/quarkus-build-test-deploy.yaml -n ${CICD_PROJECT}

oc delete PipelineRun -l tekton.dev/pipeline=quarkus-deploy -n ${CICD_PROJECT}

tkn pipeline start quarkus-build-test-deploy \
    -w name=shared-workspace,volumeClaimTemplateFile=${APP}-${PROFILE}-pipeline-pvc.yaml \
    -w name=maven-settings,config=custom-maven-settings \
    -w name=truststore,config=${APP}-${PROFILE}-kafka-truststore \
    -w name=application-properties,config=${APP}-${PROFILE}-application-properties \
    -p APP_NAME=${APP} \
    -p APP_DIR=${APP_DIR} \
    -p HTTP_CONTEXT=${HTTP_CONTEXT} \
    -p DEPLOY_PROJECT=${DEPLOY_PROJECT} \
    -p GIT_REPO=https://github.com/justindav1s/quarkus-kafka-tekton.git \
    -p GIT_BRANCH=main \
    -p APP_PROFILE=${PROFILE} \
    -p CONTEXT_DIR=${APP} \
    -p IMAGE_REPO=${QUAYIO_HOST}/${QUAYIO_USER} \
    --use-param-defaults \
    --showlog \
     -n ${CICD_PROJECT}
