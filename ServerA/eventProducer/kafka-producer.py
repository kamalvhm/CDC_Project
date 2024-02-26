from confluent_kafka import Producer
import json

# Configure Kafka producer ,PRODUCER IS TO TEST KAFKA FLOW
producer_config = {'bootstrap.servers': 'cdc-kafka-broker:9092'}
producer = Producer(producer_config)

# Read Debezium events and send to Kafka
with open('debezium-events.json') as f:
    for line in f:
        producer.produce('cdc-kafka-topic', key='key', value=json.loads(line))
        producer.flush()

# Close the producer
producer.close()
