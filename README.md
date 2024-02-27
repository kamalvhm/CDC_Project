# CDC Project with Debezium, Kafka, and Hive

This project demonstrates a basic implementation of a Change Data Capture (CDC) system using Debezium, Kafka, and Hive.

## Project Structure

- `docker-compose.yml`: Docker Compose file defining services for MySQL, Debezium Kafka Producer, Kafka, Zookeeper, and Hive.
- `Dockerfile.debezium-kafka-producer`: Dockerfile for the Debezium MySQL Connector and Kafka Producer.
- `Dockerfile.kafka`: Dockerfile for Apache Kafka.
- `Dockerfile.hive`: Dockerfile for Apache Hive.
- `kafka-producer.py`: Python Test script to produce Debezium events to Kafka.
- `consume_kafka.hql`: Hive script to consume Kafka messages and update Hive table.
- `server.properties`: Kafka server properties file.

## Prerequisites

- Docker and Docker Compose installed on your machine.

## Usage

1. Clone this repository:

    ```bash
    git clone https://github.com/yourusername/cdc-project.git
    cd cdc-project
    ```

2. Download the Debezium Connector JAR from [Debezium Downloads](https://debezium.io/download.html) and place it in the project folder as `debezium-connector.jar`.

3. Adjust configurations in `docker-compose.yml` and other files as needed.

4. Build and run the Docker containers:

    ```bash

    docker-compose up

    ```
   

5. Execute the Hive script to consume Kafka messages:

    ```bash
    docker exec -it cdc_project_hive_1 hive -f /docker-entrypoint-initdb.d/consume_kafka.hql
    ```

## Notes

- Replace placeholder values in configuration files with your actual configurations.
- This is a basic example. Adjust configurations based on your specific use case and environment.


## Create a sample Hive table
```
CREATE TABLE hive_table (
    id INT,
    name STRING,
    email STRING
);
```

# Instructions 

## Server A 'SOURCE' (MySQL with Debezium and Kafka)
1. Install Docker and Docker Compose:
```
# Install Docker
sudo apt update
sudo apt install -y docker.io

# Install Docker Compose
sudo apt install -y docker-compose

# Add your user to the docker group (to avoid using sudo with docker commands)
sudo usermod -aG docker $USER

# Log out and log back in to apply the group changes

```
2. Clone the CDC project repository:
```
git clone https://github.com/yourusername/cdc-project.git
cd cdc-project

```
4. Adjust Configurations:
Open docker-compose.yml and update placeholder values with your actual configurations.

5. Build and Run Docker Containers:
```
docker-compose up
```
6. Register configurations from debezium-mysql-connector container by using below curl command (for every new table we can register conf ,also mutiple table can be configured is same change 'public.users' to 'sample_db.users' if below does not work)
```
docker exec -it <ContainerId> /bin/bash

curl -i -X POST -H "Accept:application/json" -H  "Content-Type:application/json" http://debezium-mysql-connector:8083/connectors/ -d '
{
  "name": "mysql-db-connector",
  "config": {

	"connector.class": "io.debezium.connector.mysql.MySqlConnector",
    "database.dbname": "sample_db",
    "database.history.kafka.bootstrap.servers": "kafka:9093",
    "database.history.kafka.topic": "cdc-kafka-topic",
    "database.hostname": "mysql",
    "database.password": "mysql",
    "database.port": "3306",
    "database.server.name": "mysql",
    "database.user": "mysql",
    "database.allowPublicKeyRetrieval":"true",
    "name": "mysql-db-connector",
    "plugin.name": "mysqloutput",
    "table.include.list": "sample_db.users",
    "tasks.max": "1",
    "topic.creation.default.cleanup.policy": "delete",
    "topic.creation.default.partitions": "1",
    "topic.creation.default.replication.factor": "1",
    "topic.creation.default.retention.ms": "604800000",
    "topic.creation.enable": "true",
    "topic.prefix": "mysql"
	}
}'

```
7. Open mysql container and create database, table,update previllages (SKIP THIS STEP) 
```
docker exec -it <container Id> bash
root@a110fe08e4b6:/# mysql -u mysql -p
Enter password:
show databases;
show tables;
CREATE DATABASE sample_db;
USE sample_db;

CREATE TABLE users (
    id INT PRIMARY KEY,
    name VARCHAR(255),
    email VARCHAR(255)
);  

//To grant permissions login with root
    mysql>GRANT ALL ON sample_db.* TO 'mysql'@'%';
    mysql>select Super_priv,Repl_client_priv  from mysql.user where user='mysql';
    mysql>grant replication client  on *.* TO 'mysql'@'%';
    mysql>grant super on *.* TO 'mysql'@'%'; 
    mysql>grant LOCK TABLES  on *.* TO 'mysql'@'%';
    mysql>grant RELOAD   on *.* TO 'mysql'@'%';
    mysql>grant REPLICATION SLAVE on *.* TO 'mysql'@'%';
    ##SET log_BIN 
    mysql>SET sql_log_bin = ON
    ##CHECK log bin 
    mysql>show binary logs;
    mysql> FLUSH PRIVILEGES;
    ##VARIBALE TO CHECK 
    SHOW VARIABLES LIKE 'server_id';
    SHOW VARIABLES LIKE 'log_bin';
    SHOW VARIABLES LIKE 'binlog_format';
    SHOW VARIABLES LIKE 'binlog_row_image';
    SHOW VARIABLES LIKE 'expire_logs_days';
``` 

## Server B 'DESTINATION' (Hive)
1. Install Docker and Docker Compose (if not installed):
```
# Install Docker
sudo apt update
sudo apt install -y docker.io

# Install Docker Compose
sudo apt install -y docker-compose

# Add your user to the docker group (to avoid using sudo with docker commands)
sudo usermod -aG docker $USER

# Log out and log back in to apply the group changes

```

2. Clone the CDC project repository:
```
git clone https://github.com/yourusername/cdc-project.git
cd cdc-project

```
3. Adjust Configurations:
Open docker-compose.yml and update placeholder values with your actual configurations.

inspect connector configuration so that we can update topic name in server B
```
curl -i -X GET http://debezium-connector-host:8083/connectors/your-connector-name/config
```

4. Build and Run Docker Containers:
`
docker-compose up

`
5. Execute Hive Script:
After the Docker containers are up and running, open a new terminal window, navigate to the project folder, and run the following command to execute the Hive script:
```
docker exec -it cdc_project_hive_1 hive -f /docker-entrypoint-initdb.d/consume_kafka.hql

```
Replace cdc_project_hive_1 with the actual name of your Hive container.

This completes the basic deployment. Make sure to replace placeholder values, such as yourusername and adjust configurations based on your specific use case and environment


## Connector commands 
In case of connector failure, some times restating connector tasks works
```
curl -XPOST http://localhost:8083/connectors/connector_name/restart
curl -XPOST http://localhost:8083/connectors/connector_name/tasks/n/restart
curl -XPUT  http://localhost:8083/connectors/connector_name/pause
curl -XPUT  http://localhost:8083/connectors/connector_name/resume

curl -i http://debezium-connector-host:8083/connectors/debezium-mysql-connector/status

curl http://localhost:8083/connector-plugins
# DELETE
curl -i -X DELETE localhost:8083/connectors/inventory-connector/
# UPDATE 
curl -i -X PUT -H "Accept:application/json" -H "Content-Type:application/json" localhost:8083/connectors/inventory-connector/config -d '{ "connector.class": "io.debezium.connector.mysql.MySqlConnector", "tasks.max": "1", "database.hostname": "mysql", "database.port": "3306", "database.user": "debezium", "database.password": "dbz", "database.server.id": "184054", "database.server.name": "dbserver1", "database.include.list": "inventory", "database.history.kafka.bootstrap.servers": "kafka:9092", "database.history.kafka.topic": "dbhistory.inventory" }'


```
## Kafka commands 
```
docker exec -it <containerId> /bin/bash

# List Topics
kafka-topics.sh --list --bootstrap-server localhost:9092
# Create 
kafka-topics.sh --bootstrap-server localhost:9092 --topic first_topic --create --partitions 3 --replication-factor 1
#Delete
kafka-topics.sh --bootstrap-server localhost:9092 --delete --topic my_connect_offsets
#Check
kafka-console-consumer.sh --bootstrap-server localhost:9092 --from-beginning --property print.key=true --topic cdc-kafka-topic
Cntrl+C to exit topic

```