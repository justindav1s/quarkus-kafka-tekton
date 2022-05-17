#!/bin/bash

IMAGE=quarkus-native-builder
REGISTRY_HOST=quay.io
REPO=justindav1s
VERSION=latest

docker build -t $IMAGE - < Dockerfile

TAG=$REGISTRY_HOST/$REPO/$IMAGE:$VERSION

docker tag $IMAGE $TAG

docker push $TAG