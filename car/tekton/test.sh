#!/bin/bash


PROJECT=connected
APP=car
PROFILE=dev

oc delete configmap ${APP}-${PROFILE}-config ${APP}-${PROFILE}-user-truststore

oc create configmap ${APP}-${PROFILE}-config \
    --from-file=../src/main/resources/config.${PROFILE}.properties \
    -n ${PROJECT}

oc create configmap ${APP}-${PROFILE}-user-truststore \
    --from-file=../truststore/user-truststore.jks \
    -n ${PROJECT}

oc label configmap ${APP}-${PROFILE}-config app=${APP}
oc label configmap ${APP}-${PROFILE}-user-truststore app=${APP}

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

oc apply -f pipelines/maven-build-test-deploy.yaml

tkn pipeline start maven-build-test-deploy \
    -w name=shared-workspace,volumeClaimTemplateFile=${APP}-${PROFILE}-pipeline-pvc.yaml \
    -w name=maven-settings,config=custom-maven-settings \
    -w name=truststore,config=${APP}-${PROFILE}-user-truststore \
    -p APP_NAME=${APP} \
    -p GIT_REPO=https://github.com/justindav1s/microservices-on-openshift.git \
    -p GIT_BRANCH=master \
    -p APP_PROFILE=${PROFILE} \
    -p CONTEXT_DIR=src/quarkus/${APP} \
    -p IMAGE_REPO=${QUAYIO_HOST}/${QUAYIO_USER} \
    --use-param-defaults \
    --showlog
