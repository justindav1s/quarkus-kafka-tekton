#!/bin/bash


URL=http://localhost:8080

echo
echo Using URL : ${URL}
curl -X GET $URL/ccars/list
echo
curl -d "@car.json" -H "Content-Type: application/json" -X POST $URL/ccars/add
echo


 