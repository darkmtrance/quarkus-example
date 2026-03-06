package com.workshop;

import static io.restassured.RestAssured.given;
import static org.hamcrest.CoreMatchers.is;
import static org.hamcrest.CoreMatchers.notNullValue;

import org.junit.jupiter.api.Test;

import io.quarkus.test.junit.QuarkusTest;

@QuarkusTest
public class HelloResourceTest {

  @Test
  public void testHelloEndpoint() {
    given()
        .when().get("/api/hello")
        .then()
        .statusCode(200)
        .body("content", is("¡Hola Indra desde Quarkus!"))
        .body("timestamp", notNullValue())
        .body("version", is("1.0.0"));
  }

  @Test
  public void testHealthEndpoint() {
    given()
        .when().get("/api/health")
        .then()
        .statusCode(200)
        .body("content", is("Sistema operativo"))
        .body("timestamp", notNullValue());
  }

  @Test
  public void testInfoEndpoint() {
    given()
        .when().get("/api/info")
        .then()
        .statusCode(200)
        .body("applicationName", is("quarkus-hello-api"))
        .body("version", is("1.0.0"))
        .body("javaVersion", notNullValue());
  }

  @Test
  public void testQuarkusHealthCheck() {
    given()
        .when().get("/health")
        .then()
        .statusCode(200);
  }
}
