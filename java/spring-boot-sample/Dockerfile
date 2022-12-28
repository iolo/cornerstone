FROM gradle:jdk17-alpine as builder

WORKDIR /app
COPY gradle.xml .
COPY settings.xml .
COPY src ./src

RUN gradle build

FROM openjdk:17-alpine

COPY --from=builder /app/target/cornerstone-task-*.jar /cornerstone-task.jar

CMD ["java", "-XX:MaxRAMPercentage=80", "-Djava.security.egd=file:/dev/./urandom", "-jar", "/cornerstone-task.jar"]
