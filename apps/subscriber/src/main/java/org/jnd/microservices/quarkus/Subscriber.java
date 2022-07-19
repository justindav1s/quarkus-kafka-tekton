package org.jnd.microservices.quarkus;

import javax.enterprise.event.Observes;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.MediaType;
import org.jboss.logging.Logger;

import javax.ws.rs.core.UriInfo;
import javax.ws.rs.core.Request;

import io.quarkus.runtime.StartupEvent;
import io.quarkus.runtime.configuration.ProfileManager;

@Path("/")
public class Subscriber {

    private static final Logger log = Logger.getLogger(Subscriber.class.getName());

    void onStart(@Observes StartupEvent ev) {
        log.info("The application is starting with profile : " + ProfileManager.getActiveProfile());
    }


    @GET
    @Path("/healthz")
    @Produces(MediaType.TEXT_PLAIN)
    public String health() {
        return "OK";
    }

    @GET
    @Path("/echo/{data}")
    @Produces(MediaType.APPLICATION_JSON)
    public String all(@PathParam("data") String data, @Context UriInfo uriInfo, @Context Request req) {

        log.info(req.getMethod()+" "+uriInfo.getRequestUri());

        return "From Subscriber : "+data;
    }

    @POST
    @Path("")
    @Produces(MediaType.APPLICATION_JSON)
    public String receive(String data, @Context UriInfo uriInfo, @Context Request req) {

        log.info("Received data : "+data);
        log.info(req.getMethod()+" "+uriInfo.getRequestUri());

        data = ("{\"data\": \"from the subscriber\"}");
        log.info("Returning data : "+data);

        return data;
    }


}