package org.jnd.car.controller;

import static io.restassured.RestAssured.given;
import static org.junit.jupiter.api.Assertions.*;

import java.util.UUID;

import org.junit.jupiter.api.Test;

import io.quarkus.test.junit.QuarkusTest;

import org.jboss.logging.Logger;

@QuarkusTest
public class CarsResourceTest {

    private static final Logger LOG = Logger.getLogger(CarsResourceTest.class);

    @Test
    void testHealthEndpoint() {

        LOG.info("testing testHealthEndpoint");

        String body = given()
                .when()
                .get("/cars/health")
                .then()
                .extract().body()
                .asString();
        assertEquals(body, "OK");       
    }

    @Test
    void testQuotesEventStream() {

        LOG.info("testing");

        String requestBody = "{\"id\":\"1\",\"state\":\"locked\"}";

        String body = given()
                .header("Content-type", "application/json")
                .and()
                .body(requestBody)
                .when()
                .post("/cars/request")
                .then()
                .extract().body()
                .asString();
        assertEquals(requestBody, body);       
    }
}
