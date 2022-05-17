#!/bin/bash


PROJECT=connected
APP=cars
PROFILE=dev

oc delete configmap ${APP}-${PROFILE}-config ${APP}-${PROFILE}-kafka-truststore

oc create configmap ${APP}-${PROFILE}-config \
    --from-file=../src/main/resources/config.${PROFILE}.properties \
    -n ${PROJECT}

oc create configmap ${APP}-${PROFILE}-kafka-truststore \
    --from-file=../truststore/kafka-truststore.jks \
    -n ${PROJECT}

oc label configmap ${APP}-${PROFILE}-config app=${APP}
oc label configmap ${APP}-${PROFILE}-kafka-truststore app=${APP}

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

oc apply -f tasks/run-script-task.yaml
oc apply -f tasks/oc-deploy-template.yaml
oc apply -f tasks/quarkus-native-build.yaml
oc apply -f pipelines/quarkus-native-build-test-deploy.yaml

oc delete PipelineRun -l tekton.dev/pipeline=quarkus-deploy

tkn pipeline start quarkus-native-build-test-deploy \
    -w name=shared-workspace,volumeClaimTemplateFile=${APP}-${PROFILE}-pipeline-pvc.yaml \
    -w name=maven-settings,config=custom-maven-settings \
    -w name=truststore,config=${APP}-${PROFILE}-kafka-truststore \
    -p APP_NAME=${APP} \
    -p GIT_REPO=https://github.com/justindav1s/quarkus-kafka-tekton.git \
    -p GIT_BRANCH=main \
    -p APP_PROFILE=${PROFILE} \
    -p CONTEXT_DIR=${APP} \
    -p IMAGE_REPO=${QUAYIO_HOST}/${QUAYIO_USER} \
    --use-param-defaults \
    --showlog
