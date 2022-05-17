package org.jnd.car.model;

import io.quarkus.kafka.client.serialization.ObjectMapperDeserializer;

public class CarDeserializer extends ObjectMapperDeserializer<Car> {
    public CarDeserializer() {
        super(Car.class);
    }
}
