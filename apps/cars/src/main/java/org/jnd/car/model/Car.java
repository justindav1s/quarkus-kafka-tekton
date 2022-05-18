package org.jnd.car.model;

public class Car {

    public String id;
    public String state;

    /**
     * Default constructor required for Jackson serializer
     */
    public Car() { }

    public Car(String id, String state) {
        this.id = id;
        this.state = state;
    }

    @Override
    public String toString() {
        return "{" +
                " \"id\": \"" + id + '\"' +
                ", \"state\": \"" + state +
                "\" }";
    }
}