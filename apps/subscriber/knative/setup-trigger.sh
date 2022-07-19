#!/bin/bash

oc -n knative-test apply -f - << END
apiVersion: eventing.knative.dev/v1alpha1
kind: Trigger
metadata:
  name: subscriber-1
spec:
  filter:
    attributes:
      type: test.request
  subscriber:
    ref:
     apiVersion: v1
     kind: Service
     name: subscriber
END