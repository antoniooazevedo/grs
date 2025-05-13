CREATE KEYSPACE IF NOT EXISTS dynamo WITH replication = {'class': 'NetworkTopologyStrategy', 'replication_factor': 3};

CREATE TABLE IF NOT EXISTS dynamo.users (
    id int PRIMARY KEY,
    name text
);
