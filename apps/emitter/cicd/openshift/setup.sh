#!/usr/bin/env bash


. ../../../../env.sh

.  ../../env.sh

oc login https://${IP} -u $USER


# echo Deleting $PROJECT
# oc delete project $PROJECT
# echo Creating $PROJECT
# oc new-project $PROJECT 2> /dev/null
# while [ $? \> 0 ]; do
#     sleep 1
#     printf "."
# oc new-project $PROJECT 2> /dev/null
# done

oc delete secret quayio-dockercfg -n $CICD_PROJECT
oc delete secret quayio-dockercfg -n $PROJECT

oc create secret docker-registry quayio-dockercfg \
  --docker-server=${QUAYIO_REGISTRY} \
  --docker-username=${QUAYIO_USER} \
  --docker-password=${QUAYIO_PASSWORD} \
  --docker-email=${QUAYIO_EMAIL} \
  -n $PROJECT

oc secrets link builder quayio-dockercfg -n $PROJECT
oc secrets link default quayio-dockercfg -n $PROJECT

oc policy add-role-to-user edit system:serviceaccount:${CICD_PROJECT}:jenkins -n ${PROJECT}
oc policy add-role-to-user edit system:serviceaccount:${CICD_PROJECT}:default -n ${PROJECT}
