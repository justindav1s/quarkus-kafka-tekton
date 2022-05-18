#!/bin/bash

# URL=https://cars-native-connected.apps.sno.openshiftlabs.net
URL=https://cars-connected.apps.sno.openshiftlabs.net
# URL=https://cars-serverless-connected.apps.sno.openshiftlabs.net

echo Using URL : ${URL}

curl -X GET $URL/cars/health
echo
curl -X GET $URL/q/openapi
echo
curl -v -d "@car.json" -H "Content-Type: application/json" -X POST $URL/cars/request

