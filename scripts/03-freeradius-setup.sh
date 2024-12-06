#!/bin/bash
set -e

source ../config/radius.conf

echo "Starting FreeRADIUS setup..."

# Backup original configurations
cp /etc/freeradius/3.0/radiusd.conf /etc/freeradius/3.0/radiusd.conf.orig
cp /etc/freeradius/3.0/clients.conf /etc/freeradius/3.0/clients.conf.orig

# Configure main settings
sed -i "s/^#\?.*listen {/listen {/g" /etc/freeradius/3.0/radiusd.conf
sed -i "s/^#\?.*ipaddr = .*/    ipaddr = ${RADIUS_LISTEN_IP}/g" /etc/freeradius/3.0/radiusd.conf

# Configure clients
cat > /etc/freeradius/3.0/clients.conf << EOF
client private-network {
    ipaddr = ${RADIUS_CLIENT_NETWORK}
    secret = ${RADIUS_CLIENT_SECRET}
    require_message_authenticator = no
}
EOF

# Set permissions
chown -R freerad:freerad /etc/freeradius/3.0/
chmod -R 640 /etc/freeradius/3.0/
chmod -R u+X /etc/freeradius/3.0/

# Start and enable service
systemctl enable freeradius
systemctl restart freeradius

echo "FreeRADIUS setup completed!"