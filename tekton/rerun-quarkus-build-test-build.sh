#!/bin/bash

. ../env.sh

PIPELINE=quarkus-build-test-build

oc project ${CICD_PROJECT}

LAST_RUN=$(tkn pipelinerun list -n ${CICD_PROJECT} | grep ${PIPELINE} | head -1 | awk {'print $1'})

tkn pipeline start ${PIPELINE} --use-pipelinerun ${LAST_RUN} --showlog
