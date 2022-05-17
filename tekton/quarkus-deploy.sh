#!/bin/bash


PROJECT=connected
APP=cars
CONTEXT=${APP}
PROFILE=dev

oc delete configmap ${APP}-${PROFILE}-config ${APP}-${PROFILE}-kafka-truststore

oc create configmap ${APP}-${PROFILE}-config \
    --from-file=../src/main/resources/config.${PROFILE}.properties \
    -n ${CICD_PROJECT}

oc create configmap ${APP}-${PROFILE}-kafka-truststore \
    --from-file=../truststore/kafka-truststore.jks \
    -n ${CICD_PROJECT}

oc label configmap ${APP}-${PROFILE}-config app=${APP}
oc label configmap ${APP}-${PROFILE}-kafka-truststore app=${APP}

cat << EOF > ${APP}-${PROFILE}-pipeline-pvc.yaml
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
oc apply -f tasks/oc-deploy-template.yaml
oc apply -f pipelines/quarkus-deploy.yaml

oc delete PipelineRun -l tekton.dev/pipeline=quarkus-deploy

tkn pipeline start quarkus-deploy \
    -w name=shared-workspace,volumeClaimTemplateFile=${APP}-${PROFILE}-pipeline-pvc.yaml \
    -w name=truststore,config=${APP}-${PROFILE}-kafka-truststore \
    -p APP_NAME=${APP} \
    -p CONTEXT_DIR=${CONTEXT} \
    -p GIT_REPO=https://github.com/justindav1s/quarkus-kafka-tekton.git \
    -p GIT_BRANCH=main \
    -p APP_PROFILE=${PROFILE} \
    -p IMAGE_REPO=${QUAYIO_HOST}/${QUAYIO_USER} \
    --use-param-defaults \
    --showlog
