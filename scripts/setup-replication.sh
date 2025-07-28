#!/bin/bash

# MariaDB Master-Slave Replication Setup Script
# This script configures replication after both containers are running

echo "Setting up MariaDB Master-Slave Replication..."

# Wait for master to be ready
echo "Waiting for master database to be ready..."
until docker exec webstack-mariadb-master mariadb -uroot -p12345 -e "SELECT 1" >/dev/null 2>&1; do
    echo "Master not ready, waiting..."
    sleep 5
done

# Wait for slave to be ready
echo "Waiting for slave database to be ready..."
until docker exec webstack-mariadb-slave mariadb -uroot -p12345 -e "SELECT 1" >/dev/null 2>&1; do
    echo "Slave not ready, waiting..."
    sleep 5
done

echo "Both databases are ready. Setting up replication..."

# Create replication user on master
echo "Creating replication user on master..."
docker exec webstack-mariadb-master mariadb -uroot -p12345 -e "
DROP USER IF EXISTS 'replicator'@'%';
DROP USER IF EXISTS 'replicator'@'172.20.0.%';
CREATE USER 'replicator'@'%' IDENTIFIED BY 'repl123';
CREATE USER 'replicator'@'172.20.0.%' IDENTIFIED BY 'repl123';
GRANT REPLICATION SLAVE ON *.* TO 'replicator'@'%';
GRANT REPLICATION SLAVE ON *.* TO 'replicator'@'172.20.0.%';
FLUSH PRIVILEGES;
"

# Verify user creation
echo "Verifying replication user..."
docker exec webstack-mariadb-master mariadb -uroot -p12345 -e "SELECT User, Host FROM mysql.user WHERE User='replicator';"

# Test connection from slave to master
echo "Testing replication user connection from slave..."
if docker exec webstack-mariadb-slave mariadb -h database -u replicator -prepl123 -e "SELECT 1" >/dev/null 2>&1; then
    echo "✅ Replication user can connect successfully"
else
    echo "❌ Replication user cannot connect. Checking network connectivity..."
    docker exec webstack-mariadb-slave ping -c 2 database
    echo "Trying to connect with verbose output..."
    docker exec webstack-mariadb-slave mariadb -h database -u replicator -prepl123 -e "SELECT 1"
    exit 1
fi

# Get master status
echo "Getting master status..."
MASTER_STATUS=$(docker exec webstack-mariadb-master mariadb -uroot -p12345 -e "SHOW MASTER STATUS\G")
MASTER_FILE=$(echo "$MASTER_STATUS" | grep "File:" | awk '{print $2}')
MASTER_POS=$(echo "$MASTER_STATUS" | grep "Position:" | awk '{print $2}')

echo "Master file: $MASTER_FILE"
echo "Master position: $MASTER_POS"

# Validate master status
if [ -z "$MASTER_FILE" ] || [ -z "$MASTER_POS" ]; then
    echo "Error: Could not get master status. Check if binary logging is enabled."
    echo "Master status output:"
    echo "$MASTER_STATUS"
    exit 1
fi

# Reset slave first to clear any existing configuration
echo "Resetting slave configuration..."
docker exec webstack-mariadb-slave mariadb -uroot -p12345 -e "
STOP SLAVE;
RESET SLAVE ALL;
"

# Configure slave
echo "Configuring slave replication..."
docker exec webstack-mariadb-slave mariadb -uroot -p12345 -e "
CHANGE MASTER TO
    MASTER_HOST='database',
    MASTER_PORT=3306,
    MASTER_USER='replicator',
    MASTER_PASSWORD='repl123',
    MASTER_LOG_FILE='$MASTER_FILE',
    MASTER_LOG_POS=$MASTER_POS;
START SLAVE;
"

# Check slave status
echo "Checking slave status..."
SLAVE_STATUS=$(docker exec webstack-mariadb-slave mariadb -uroot -p12345 -e "SHOW SLAVE STATUS\G")
IO_RUNNING=$(echo "$SLAVE_STATUS" | grep "Slave_IO_Running:" | awk '{print $2}')
SQL_RUNNING=$(echo "$SLAVE_STATUS" | grep "Slave_SQL_Running:" | awk '{print $2}')
LAST_ERROR=$(echo "$SLAVE_STATUS" | grep "Last_Error:" | cut -d: -f2- | xargs)

echo "Slave_IO_Running: $IO_RUNNING"
echo "Slave_SQL_Running: $SQL_RUNNING"

if [ "$LAST_ERROR" != "" ]; then
    echo "Last_Error: $LAST_ERROR"
fi

if [ "$IO_RUNNING" = "Yes" ] && [ "$SQL_RUNNING" = "Yes" ]; then
    echo "✅ Replication setup complete and working!"
else
    echo "⚠️  Replication setup completed but may have issues."
    echo "Full slave status:"
    echo "$SLAVE_STATUS"
fi
echo ""
echo "To verify replication is working:"
echo "1. Create a test database on master:"
echo "   docker exec webstack-mariadb-master mariadb -uroot -p12345 -e 'CREATE DATABASE test_replication;'"
echo ""
echo "2. Check if it appears on slave:"
echo "   docker exec webstack-mariadb-slave mariadb -uroot -p12345 -e 'SHOW DATABASES;'"