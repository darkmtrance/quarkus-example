package com.workshop.model;

public record InfoResponse(
    String applicationName,
    String version,
    String description,
    String javaVersion,
    String osName
) {
}
