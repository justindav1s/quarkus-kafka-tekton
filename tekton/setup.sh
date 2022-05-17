#!/bin/bash


. ../env.sh

echo Deleting $CICD_PROJECT
oc delete project $CICD_PROJECT
echo Creating $CICD_PROJECT
oc new-project $CICD_PROJECT 2> /dev/null
while [ $? \> 0 ]; do
    sleep 1
    printf "."
oc new-project $CICD_PROJECT 2> /dev/null
done

echo Deleting $DEPLOY_PROJECT
oc delete project $DEPLOY_PROJECT
echo Creating $DEPLOY_PROJECT
oc new-project $DEPLOY_PROJECT 2> /dev/null
while [ $? \> 0 ]; do
    sleep 1
    printf "."
oc new-project $DEPLOY_PROJECT 2> /dev/null
done

oc create secret docker-registry quay-dockercfg \
  --docker-server=${QUAYIO_HOST} \
  --docker-username=${QUAYIO_USER} \
  --docker-password=${QUAYIO_PASSWORD} \
  --docker-email=${QUAYIO_EMAIL} \
  -n ${CICD_PROJECT}

oc secrets link pipeline quay-dockercfg -n ${CICD_PROJECT}
oc secrets link deployer quay-dockercfg --for=pull -n ${CICD_PROJECT}
oc create configmap custom-maven-settings --from-file=settings.xml -n ${CICD_PROJECT}

oc policy add-role-to-user edit system:serviceaccount:${CICD_PROJECT}:pipeline -n ${DEPLOY_PROJECT}
