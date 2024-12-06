#!/bin/bash
set -e

source ../config/database.conf

echo "Starting MySQL setup..."

# Secure MySQL installation
mysql_secure_installation

# Create database and user
mysql -e "CREATE DATABASE IF NOT EXISTS ${DB_NAME};"
mysql -e "CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';"
mysql -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"

# Import schemas
mysql ${DB_NAME} < ../sql/radius-schema.sql
mysql ${DB_NAME} < ../sql/portal-schema.sql

# Setup backup directory
mkdir -p ${BACKUP_DIR}
chmod 700 ${BACKUP_DIR}

echo "MySQL setup completed!"