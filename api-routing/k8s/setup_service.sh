#!/bin/bash

oc apply -f - << END
apiVersion: v1
kind: Service
metadata:
  name: restcountries1
spec:
  type: ExternalName
  externalName: restcountries.eu
END

# curl -v http://restcountries1/rest/v2/name/uk -H "Host: restcountries.eu" WORKS, hosted behind CloudFlare which needs Host header
# curl -vk http://restcountries1/rest/v2/name/uk -H "Host: restcountries.eu" WORKS

oc apply -f - << END
apiVersion: v1
kind: Service
metadata:
  name: inventory
spec:
  type: ExternalName
  externalName: inventory-amazin-dev.apps.ocp4.datr.eu
END

# curl -v http://inventory/products/all does not work
# curl -v http://inventory/products/all -H "Host: inventory-amazin-dev.apps.ocp4.datr.eu" WORKS, ocp router needs accurate Hosts header in order to route traffic
# curl -vk https://inventory/products/all -H "Host: inventory-amazin-dev.apps.ocp4.datr.eu" WORKS
# curl -v https://inventory/products/all -H "Host: inventory-amazin-dev.apps.ocp4.datr.eu" does not work

oc apply -f - << END
apiVersion: v1
kind: Service
metadata:
  name: httpbin1
spec:
  type: ExternalName
  externalName: httpbin.org
END


# curl -v http://httpbin1/anything WORKS
# curl -v https://httpbin1/anything does not work as httpbin1 not in cert
# curl -vk https://httpbin1/anything WORKS, because curl isn't checking hosts.