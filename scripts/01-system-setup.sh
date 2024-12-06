#!/bin/bash
set -e

echo "Starting system setup..."

# Update system
apt update && apt upgrade -y

# Install essential packages
apt install -y \
    curl \
    wget \
    git \
    nginx \
    mysql-server \
    php-fpm \
    php-mysql \
    php-curl \
    php-json \
    php-gd \
    php-mbstring \
    freeradius \
    freeradius-mysql \
    freeradius-utils

# Configure firewall
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 1812/udp
ufw allow 1813/udp

echo "System setup completed!"