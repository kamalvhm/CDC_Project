# Dockerfile for Debezium MySQL Connector and Kafka Producer

FROM openjdk:11

WORKDIR /app

COPY /connector/debezium-connector-mysql-1.7.1.Final.jar /app
COPY /eventProducer/kafka-producer.py /app

CMD ["java", "-jar", "debezium-connector.jar"]   # Replace with the actual command to run the Debezium connector