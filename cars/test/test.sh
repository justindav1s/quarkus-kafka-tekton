#!/bin/bash

URL=https://cars-native-connected.apps.sno.openshiftlabs.net
#URL=https://cars-connected.apps.sno.openshiftlabs.net

echo Using URL : ${URL}

curl -X GET $URL/cars/health
echo
curl -d "@car.json" -X POST $URL/cars/request
echo
curl -X GET $URL/q/openapi
