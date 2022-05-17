#!/bin/bash

IMAGE=quarkus-native-builder
REGISTRY_HOST=quay.io
REPO=justindav1s
VERSION=gcr-mvn-mandrel22

DOCKER_BUILDKIT=0 docker build -t $IMAGE - < Dockerfile.gcr-mvn-mandrel22

TAG=$REGISTRY_HOST/$REPO/$IMAGE:$VERSION

docker tag $IMAGE $TAG

docker push $TAG