#!/bin/bash
set -e

source ../config/unifi.conf

echo "Starting UniFi integration setup..."

# Install Python requirements
apt install -y python3-pip
pip3 install requests urllib3 python-dotenv

# Create sites directory
mkdir -p /var/www/hotspot/sites

# Copy integration scripts
cp ../src/unifi_integration.py /var/www/hotspot/app/
cp ../src/site_manager.py /var/www/hotspot/app/

# Configure base integration
cat > /var/www/hotspot/config/unifi.php << EOF
<?php
return [
    'controller_url' => '${UNIFI_CONTROLLER_URL}',
    'username' => '${UNIFI_USER}',
    'password' => '${UNIFI_PASS}',
    'radius_secret' => '${UNIFI_RADIUS_SECRET}',
    'radius_port' => ${UNIFI_RADIUS_PORT}
];
EOF

# Create site configuration template
cat > /var/www/hotspot/config/site.template.php << EOF
<?php
return [
    'site_id' => '{{SITE_ID}}',
    'site_name' => '{{SITE_NAME}}',
    'ssid_prefix' => '{{SSID_PREFIX}}',
    'vlan_range' => [
        'start' => {{VLAN_START}},
        'end' => {{VLAN_END}}
    ]
];
EOF

echo "UniFi integration setup completed!"