FROM ewolff/docker-java
ADD target/microservice-demo-catalog-0.0.1-SNAPSHOT.jar .
#Removed Ilpos changes
#CMD /usr/bin/java -Xmx400m -Xms400m -Djava.security.egd=file:/dev/./urandom -jar -Deureka.client.enabled=false microservice-demo-catalog-0.0.1-SNAPSHOT.jar
CMD /usr/bin/java -Xmx400m -Xms400m -Djava.security.egd=file:/dev/./urandom -jar microservice-demo-catalog-0.0.1-SNAPSHOT.jar
EXPOSE 8080