FROM openjdk:8-jdk-alpine
RUN addgroup -S testgroup && adduser -S testuser -G testgroup
USER testuser:testgroup
ARG JAR_FILE=java/*.jar
COPY ${JAR_FILE} /tmp/test.jar
WORKDIR /tmp
ENTRYPOINT ["java","-jar","/tmp/test.jar"]
