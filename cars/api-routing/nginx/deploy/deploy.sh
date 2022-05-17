#!/bin/bash

oc project cd-improvements

oc delete all -l app=nginx-proxy

oc delete configmap proxy-conf
oc create configmap proxy-conf --from-file=proxy.conf=src/nginx-default-cfg/proxy.conf    

oc delete configmap test-data
oc create configmap test-data --from-file=enquiry-soap-req.xml=test-data/enquiry-soap-req.xml  

oc apply -f nginx-proxy.yaml