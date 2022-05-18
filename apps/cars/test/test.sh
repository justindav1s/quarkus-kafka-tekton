#!/bin/bash

URLS="https://cars-connected.apps.sno.openshiftlabs.net https://cars-native-connected.apps.sno.openshiftlabs.net https://cars-serverless-connected.apps.sno.openshiftlabs.net"
# URL=https://cars-connected.apps.sno.openshiftlabs.net
# URL=https://cars-serverless-connected.apps.sno.openshiftlabs.net


for URL in $URLS
do
    echo
    echo Using URL : ${URL}
    curl -X GET $URL/cars/health
    # echo
    # curl -X GET $URL/q/openapi
    echo
    curl -d "@car.json" -H "Content-Type: application/json" -X POST $URL/cars/request
    echo
done

 