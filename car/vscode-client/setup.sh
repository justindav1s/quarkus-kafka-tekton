#!/bin/bash

PROJECT=my-cluster2


oc get secret my-cluster2-clients-ca -n ${PROJECT} -o jsonpath='{.data.ca\.key}' | base64 --decode > ca.key
