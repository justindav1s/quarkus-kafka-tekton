#!/bin/bash

curl -X GET https://cars-connected.apps.sno.openshiftlabs.net/cars/health

curl -d "@car.json" -X POST https://cars-connected.apps.sno.openshiftlabs.net/cars/request
