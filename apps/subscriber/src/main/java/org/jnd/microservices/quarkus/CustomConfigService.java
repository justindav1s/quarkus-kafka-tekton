package org.jnd.microservices.quarkus;

import java.util.logging.Logger;

import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Request;
import javax.ws.rs.core.UriInfo;

import org.eclipse.microprofile.config.inject.ConfigProperty;

@Path("/config")
public class CustomConfigService {

    private static final Logger log = Logger.getLogger(CustomConfigService.class.getName());

    @ConfigProperty(name = "config.test.data.1", defaultValue = "no key found")
    String config_test_data_1;

    @ConfigProperty(name = "config.test.data.2", defaultValue = "no key found")
    String config_test_data_2;

    @GET
    @Path("/1")
    @Produces(MediaType.APPLICATION_JSON)
    public String data1(@Context UriInfo uriInfo, @Context Request req) {

        log.info(req.getMethod()+" "+uriInfo.getRequestUri());
        log.info("returning : "+config_test_data_1);
        return config_test_data_1;
    }

    @GET
    @Path("/2")
    @Produces(MediaType.APPLICATION_JSON)
    public String data2(@Context UriInfo uriInfo, @Context Request req) {

        log.info(req.getMethod()+" "+uriInfo.getRequestUri());
        log.info("returning : "+config_test_data_2);
        return config_test_data_2;
    }
}