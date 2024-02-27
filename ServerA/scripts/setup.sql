-- create the databases
CREATE DATABASE IF NOT EXISTS sample_db;
use sample_db;

CREATE TABLE users (
    id INT PRIMARY KEY,
    name VARCHAR(255),
    email VARCHAR(255)
);  

-- create the users for each database
-- CREATE USER 'mysql'@'%' IDENTIFIED BY 'mysql';
-- GRANT ALL , replication client, super , LOCK TABLES, RELOAD , REPLICATION SLAVE ON `sample_db`.* TO 'mysql'@'%';
GRANT ALL ON sample_db.* TO 'mysql'@'%';
grant replication client  on *.* TO 'mysql'@'%';
grant super on *.* TO 'mysql'@'%'; 
grant LOCK TABLES  on *.* TO 'mysql'@'%';
grant RELOAD   on *.* TO 'mysql'@'%';
grant REPLICATION SLAVE on *.* TO 'mysql'@'%';

SET sql_log_bin = ON;
FLUSH PRIVILEGES;