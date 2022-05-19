/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.jnd.car.controller;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.concurrent.TimeUnit;

import io.quarkus.test.junit.QuarkusTest;
import io.restassured.RestAssured;
import org.junit.jupiter.api.Test;

import static io.restassured.RestAssured.given;
import static org.junit.jupiter.api.Assertions.*;

import static org.awaitility.Awaitility.await;

import org.jboss.logging.Logger;

@QuarkusTest
public class CamelCarsTest {

    private static final Logger LOG = Logger.getLogger(CarsResourceTest.class);

    @Test
    public void testGetCars() {
        // RestAssured.get("/ccars/list")
        //         .then()
        //         .statusCode(200);

    }

    @Test
    void addCarTest() {

        LOG.info("adding car test");

        String requestBody = "{\"id\":\"23\",\"state\":\"locked\"}";

        String body = given()
                .header("Content-type", "application/json")
                .and()
                .body(requestBody)
                .when()
                .post("/ccars/add")
                .then()
                .extract().body()
                .asString();
         
        LOG.info("adding car response : "+body);        
      
    }    

}
