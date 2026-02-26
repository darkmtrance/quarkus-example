package com.workshop;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

import com.workshop.model.InfoResponse;
import com.workshop.model.Message;

import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;

@Path("/api")
public class HelloResource {

    @GET
    @Path("/hello")
    @Produces(MediaType.APPLICATION_JSON)
    public Message hello() {
        return new Message(
            "¡Hola desde Quarkus!",
            LocalDateTime.now().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME),
            "1.0.0"
        );
    }

    @GET
    @Path("/health")
    @Produces(MediaType.APPLICATION_JSON)
    public Message health() {
        return new Message(
            "Sistema operativo",
            LocalDateTime.now().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME),
            "1.0.0"
        );
    }

    @GET
    @Path("/info")
    @Produces(MediaType.APPLICATION_JSON)
    public InfoResponse info() {
        return new InfoResponse(
            "quarkus-hello-api",
            "1.0.0",
            "Azure Container Registry Workshop",
            System.getProperty("java.version"),
            System.getProperty("os.name")
        );
    }
}
