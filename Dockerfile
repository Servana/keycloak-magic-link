FROM maven:3.8.6-openjdk-11-slim as builder
RUN apt-get update && apt-get install git -y
COPY . .
RUN mvn clean install
FROM alpine:3.16
COPY --from=builder target/keycloak-magic-link-0.2-SNAPSHOT.jar /libs