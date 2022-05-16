package org.jnd.car.model;

public class Car {

    public String id;
    public int state;

    /**
     * Default constructor required for Jackson serializer
     */
    public Car() { }

    public Car(String id, int price) {
        this.id = id;
        this.state = price;
    }

    @Override
    public String toString() {
        return "Quote{" +
                "id='" + id + '\'' +
                ", state=" + state +
                '}';
    }
}