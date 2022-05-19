package org.jnd.car.controller;

import org.apache.camel.builder.RouteBuilder;
import org.apache.camel.model.rest.RestBindingMode;
import org.apache.camel.builder.endpoint.EndpointRouteBuilder;
import org.apache.camel.builder.RouteBuilder;
import org.jnd.car.model.Car;
import java.util.Set;
import java.util.Collections;
import java.util.LinkedHashSet;

public class CarsRoutes extends RouteBuilder {

    private final Set<Car> cars = Collections.synchronizedSet(new LinkedHashSet<>());

    public void Routes() {

        /* Let's add some initial fruits */

        
    }

    @Override
    public void configure() throws Exception {

        this.cars.add(new Car("1", "locked"));
        this.cars.add(new Car("2", "unlocked"));

        String kafkaendpoint = "kafka:car-requests?brokers=my-cluster-kafka-plainauth-bootstrap-kafka-cluster2.apps.sno.openshiftlabs.net:443" +
             "&sslTruststoreLocation=truststore/kafka-truststore.jks" +
             "&sslTruststorePassword=monkey123" +
             "&sslTruststoreType=JKS" +
             "&securityProtocol=SSL" +
             "&sslKeystoreLocation=truststore/mtls-user-keystore.jks" +
             "&sslKeystorePassword=dHFEb2HlfKBK" +
             "&sslKeystoreType=JKS";


        restConfiguration().bindingMode(RestBindingMode.json);

        rest("/ccars")
                .get("/list")
                .to("direct:listCars");

        rest("/ccars")
                .post("/add")
                .to("direct:addCar");

        from("direct:addCar")
                .to(kafkaendpoint);               

        from("direct:listCars")
                .setBody().constant(cars);
    }
}