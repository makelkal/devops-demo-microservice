FROM ewolff/docker-java
ADD target/microservice-demo-order-0.0.1-SNAPSHOT.jar .
EXPOSE 8080
CMD /usr/bin/java -Xmx400m -Xms400m -Djava.security.egd=file:/dev/./urandom -jar microservice-demo-order-0.0.1-SNAPSHOT.jar