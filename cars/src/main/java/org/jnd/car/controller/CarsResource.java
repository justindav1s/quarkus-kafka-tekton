package org.jnd.car.controller;

import java.util.UUID;

import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;

import org.jnd.car.model.Car;
import org.eclipse.microprofile.reactive.messaging.Channel;
import org.eclipse.microprofile.reactive.messaging.Emitter;

import io.smallrye.mutiny.Multi;

@OpenAPIDefinition(
    tags = {
            @Tag(name="car", description="Car operations."),
    },
    info = @Info(
        title="Connected Car API",
        version = "1.0.1",
        contact = @Contact(
            name = "Car API Support",
            url = "http://exampleurl.com/contact",
            email = "techsupport@example.com"),
        license = @License(
            name = "Apache 2.0",
            url = "https://www.apache.org/licenses/LICENSE-2.0.html"))
)

@Path("/cars")
public class CarsResource {

    @Channel("car-requests")
    Emitter<String> CarRequestEmitter;

    @GET
    @Path("/health")
    @Produces(MediaType.TEXT_PLAIN)
    public String health() {
        return "OK";
    }
    /**
     * Endpoint to generate a new Car request id and send it to "Car-requests" Kafka topic using the emitter.
     */
    @POST
    @Path("/request")
    @Produces(MediaType.TEXT_PLAIN)
    public String createRequest() {
        UUID uuid = UUID.randomUUID();
        CarRequestEmitter.send(uuid.toString());
        return uuid.toString();
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
