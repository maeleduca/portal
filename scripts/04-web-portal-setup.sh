#!/bin/bash
set -e

echo "Starting web portal setup..."

# Create web directory structure
mkdir -p /var/www/hotspot/{public,app/{controllers,models,views},config}

# Copy web portal files
cp -r ../src/* /var/www/hotspot/

# Configure Nginx
cat > /etc/nginx/sites-available/hotspot << EOF
server {
    listen 80;
    server_name your_domain.com;
    root /var/www/hotspot/public;

    index index.php index.html;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

# Enable site
ln -sf /etc/nginx/sites-available/hotspot /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Set permissions
chown -R www-data:www-data /var/www/hotspot
chmod -R 755 /var/www/hotspot

# Restart Nginx
systemctl restart nginx

echo "Web portal setup completed!"