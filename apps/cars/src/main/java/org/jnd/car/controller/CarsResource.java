package org.jnd.car.controller;

import java.util.UUID;
import org.jboss.logging.Logger;

import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.Consumes;
import javax.ws.rs.core.MediaType;

import org.eclipse.microprofile.reactive.messaging.Channel;
import org.eclipse.microprofile.reactive.messaging.Emitter;
import org.jnd.car.model.Car;

import io.smallrye.mutiny.Multi;


@Path("/cars")
public class CarsResource {

    private static final Logger LOG = Logger.getLogger(CarsResource.class);

    @Channel("car-requests")
    Emitter<String> CarRequestEmitter;

    @GET
    @Path("/health")
    @Produces(MediaType.TEXT_PLAIN)
    public String health() {
        LOG.info("health called");
        return "OK";
    }
    /**
     * Endpoint to generate a new Car request id and send it to "Car-requests" Kafka topic using the emitter.
     */
    @POST
    @Path("/register")
    @Consumes(MediaType.APPLICATION_JSON)
    @Produces(MediaType.APPLICATION_JSON)
    public Car createRequest(Car car) {
        LOG.info("createRequest called : "+car.toString());
        CarRequestEmitter.send(car.toString());
        return car;
    }

    @Channel("cars")
    Multi<Car> Cars;

    /**
     * Endpoint retrieving the "Cars" Kafka topic and sending the items to a server sent event.
     */
    @GET
    @Produces(MediaType.SERVER_SENT_EVENTS) // denotes that server side events (SSE) will be produced
    public Multi<Car> stream() {
        return Cars.log();
    }
}
