#!/bin/bash


PROJECT=connected


echo Deleting $PROJECT
oc delete project $PROJECT
echo Creating $PROJECT
oc new-project $PROJECT 2> /dev/null
while [ $? \> 0 ]; do
    sleep 1
    printf "."
oc new-project $PROJECT 2> /dev/null
done

oc create secret docker-registry quay-dockercfg \
  --docker-server=${QUAYIO_HOST} \
  --docker-username=${QUAYIO_USER} \
  --docker-password=${QUAYIO_PASSWORD} \
  --docker-email=${QUAYIO_EMAIL} \
  -n ${PROJECT}

sleep 1

oc secrets link pipeline quay-dockercfg -n ${PROJECT}
oc secrets link deployer quay-dockercfg --for=pull -n ${PROJECT}

oc create configmap custom-maven-settings --from-file=settings.xml
oc apply -f tasks/run-script-task.yaml
oc apply -f tasks/oc-deploy-template.yaml
oc apply -f pipelines/maven-build-test-deploy.yaml
