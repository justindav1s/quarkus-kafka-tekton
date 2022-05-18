package org.jnd.car.controller;

import static io.restassured.RestAssured.given;
import static org.junit.jupiter.api.Assertions.*;

import java.util.UUID;

import org.junit.jupiter.api.Test;

import io.quarkus.test.junit.QuarkusTest;

@QuarkusTest
public class CarsResourceTest {

    @Test
    void testQuotesEventStream() {

        String requestBody = "{\n" +
        "  \"id\": \"1\",\n" +
        "  \"state\": \"locked\",\n" +
        "\n}";

        String body = given()
                .header("Content-type", "application/json")
                .and()
                .body(requestBody)
                .when()
                .post("/cars/request")
                .then()
                .statusCode(200)
                .extract().body()
                .asString();
        assertEquals(requestBody, body);       
    }
}
