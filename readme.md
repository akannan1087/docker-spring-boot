## What is it?
This source code is an Spring Boot web application).
 
## How to run this?
```bash
$ git clone https://github.com/akannan1087/docker-spring-boot
$ cd docker-spring-boot
$ mvn clean package
$ java -jar target/spring-boot-web.jar

  access http://localhost:8080

//dockerize

// create a docker image
$ sudo docker build -t spring-boot:1.0 .
// run it
$ sudo docker run -d -p 8080:8080 -t spring-boot:1.0

  access http://localhost:8080
```
