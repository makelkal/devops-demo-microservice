FROM ewolff/docker-java
ADD target/microservice-demo-zuul-server-0.0.1-SNAPSHOT.jar .
#Ilpo! Check this out!
#CMD /usr/bin/java -Xmx600m -Xms600m -Djava.security.egd=file:/dev/./urandom -Deureka.client.enabled=false -Dcustomer.service.host=customer -Dcustomer.service.port=8080 -Dcatalog.service.host=catalog -Dcatalog.service.port=9000 -jar microservice-demo-zuul-server-0.0.1-SNAPSHOT.jar
CMD /usr/bin/java -Xmx600m -Xms600m -Djava.security.egd=file:/dev/./urandom -jar microservice-demo-zuul-server-0.0.1-SNAPSHOT.jar
EXPOSE 8080