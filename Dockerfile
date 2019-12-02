FROM openjdk:10-jre-slim
COPY ./target/web-0.0.1-SNAPSHOT.jar /usr/app/web-0.0.1-SNAPSHOT.jar
WORKDIR /usr/app
EXPOSE 8080
CMD ["java", "-jar", "web-0.0.1-SNAPSHOT.jar"]