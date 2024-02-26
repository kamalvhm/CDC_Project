-- Set up Kafka properties
SET kafka.bootstrap.servers='cdc-kafka-broker:9092';

-- Create an external table for Kafka topic
CREATE EXTERNAL TABLE kafka_topic (
    id INT,
    name STRING,
    email STRING
)
STORED BY 'org.apache.hadoop.hive.kafka.KafkaStorageHandler'
TBLPROPERTIES (
    "kafka.topic"="cdc-kafka-topic",
    "kafka.bootstrap.servers"="${hiveconf:kafka.bootstrap.servers}"
);

-- Update Hive table with real-time data from Kafka
INSERT INTO TABLE hive_table
SELECT id, name, email FROM kafka_topic;
