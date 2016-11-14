FROM ewolff/docker-java
ADD target/microservice-demo-customer-0.0.1-SNAPSHOT.jar .
CMD /usr/bin/java -Xmx400m -Xms400m -Djava.security.egd=file:/dev/./urandom -jar microservice-demo-customer-0.0.1-SNAPSHOT.jar
EXPOSE 8080