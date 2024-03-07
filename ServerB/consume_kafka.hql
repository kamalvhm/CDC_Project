-- Set up Kafka properties
SET kafka.bootstrap.servers='localhost:9092';
SET kafka.bootstrap.servers='kafka:9093';

-- Create an external table for Kafka topic
CREATE EXTERNAL TABLE users_kafka_table (
  before STRUCT<id: INT, name: STRING, email: STRING>,
  after STRUCT<id: INT, name: STRING, email: STRING>,
  source STRING,  
  op STRING,
  ts_ms BIGINT,
  transaction STRUCT<id: STRING, total_order: BIGINT, data_collection_order: BIGINT>
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.kafka.KafkaSerDe'
STORED BY 'org.apache.hadoop.hive.kafka.KafkaStorageHandler'
TBLPROPERTIES (
  "kafka.topic" = "mysql.sample_db.users",
  "kafka.bootstrap.servers" = "kafka:9093",
  "kafka.consumer.group.id" = "hive_consumer_group"
);

-- Update Hive table with real-time data from Kafka
--INSERT INTO TABLE kafka_topic
--SELECT id, name, email FROM kafka_topic;