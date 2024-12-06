#!/bin/bash

# Main installation script
set -e

# Source configuration
source config/database.conf
source config/unifi.conf
source config/radius.conf

# Create logs directory
mkdir -p logs

# Run installation scripts in order
echo "Starting installation process..."

./scripts/01-system-setup.sh 2>&1 | tee logs/01-system-setup.log
./scripts/02-mysql-setup.sh 2>&1 | tee logs/02-mysql-setup.log
./scripts/03-freeradius-setup.sh 2>&1 | tee logs/03-freeradius-setup.log
./scripts/04-web-portal-setup.sh 2>&1 | tee logs/04-web-portal-setup.log
./scripts/05-unifi-integration.sh 2>&1 | tee logs/05-unifi-integration.log

echo "Installation completed successfully!"