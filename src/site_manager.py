#!/usr/bin/env python3
import os
import json
import requests
import mysql.connector
from dotenv import load_dotenv

class UniFiSiteManager:
    def __init__(self):
        load_dotenv()
        self.db = self._connect_db()
        self.unifi_config = self._load_unifi_config()
        self.session = requests.Session()
        self._login()

    def _connect_db(self):
        return mysql.connector.connect(
            host=os.getenv('DB_HOST', 'localhost'),
            user=os.getenv('DB_USER'),
            password=os.getenv('DB_PASS'),
            database=os.getenv('DB_NAME')
        )

    def _load_unifi_config(self):
        with open('/var/www/hotspot/config/unifi.php', 'r') as f:
            config = f.read()
            # Parse PHP array to Python dict
            # This is a simple parser, you might want to use a proper PHP parser
            config = config.replace('<?php\nreturn ', '').replace(';', '')
            return eval(config)

    def _login(self):
        login_url = f"{self.unifi_config['controller_url']}/api/login"
        data = {
            'username': self.unifi_config['username'],
            'password': self.unifi_config['password']
        }
        response = self.session.post(login_url, json=data, verify=False)
        response.raise_for_status()

    def sync_sites(self):
        """Synchronize sites from UniFi Controller to local database"""
        sites_url = f"{self.unifi_config['controller_url']}/api/self/sites"
        response = self.session.get(sites_url, verify=False)
        sites = response.json()['data']

        cursor = self.db.cursor(dictionary=True)
        
        for site in sites:
            cursor.execute("""
                INSERT INTO unifi_sites (site_id, site_name, site_description)
                VALUES (%s, %s, %s)
                ON DUPLICATE KEY UPDATE
                    site_name = VALUES(site_name),
                    site_description = VALUES(site_description)
            """, (site['id'], site['name'], site.get('desc', '')))

        self.db.commit()
        cursor.close()

    def create_site_config(self, site_id):
        """Create site-specific configuration"""
        cursor = self.db.cursor(dictionary=True)
        cursor.execute("SELECT * FROM unifi_sites WHERE site_id = %s", (site_id,))
        site = cursor.fetchone()

        if not site:
            raise ValueError(f"Site {site_id} not found")

        # Create site directory
        site_dir = f"/var/www/hotspot/sites/{site_id}"
        os.makedirs(site_dir, exist_ok=True)

        # Create site configuration from template
        with open('/var/www/hotspot/config/site.template.php', 'r') as f:
            template = f.read()

        config = template.replace('{{SITE_ID}}', site_id)
        config = config.replace('{{SITE_NAME}}', site['site_name'])
        config = config.replace('{{SSID_PREFIX}}', f"HOTSPOT_{site_id}")
        config = config.replace('{{VLAN_START}}', '100')
        config = config.replace('{{VLAN_END}}', '4000')

        with open(f"{site_dir}/config.php", 'w') as f:
            f.write(config)

        cursor.close()

    def get_site_aps(self, site_id):
        """Get access points for a specific site"""
        devices_url = f"{self.unifi_config['controller_url']}/api/s/{site_id}/stat/device"
        response = self.session.get(devices_url, verify=False)
        return response.json()['data']

    def sync_site_aps(self, site_id):
        """Synchronize access points for a specific site"""
        aps = self.get_site_aps(site_id)
        cursor = self.db.cursor()

        for ap in aps:
            cursor.execute("""
                INSERT INTO ap_config (site_id, ap_name, ap_mac, location)
                SELECT s.id, %s, %s, %s
                FROM unifi_sites s
                WHERE s.site_id = %s
                ON DUPLICATE KEY UPDATE
                    ap_name = VALUES(ap_name),
                    location = VALUES(location)
            """, (ap['name'], ap['mac'], ap.get('location', ''), site_id))

        self.db.commit()
        cursor.close()

if __name__ == '__main__':
    manager = UniFiSiteManager()
    manager.sync_sites()
    
    # Sync APs for each site
    cursor = manager.db.cursor(dictionary=True)
    cursor.execute("SELECT site_id FROM unifi_sites WHERE enabled = TRUE")
    sites = cursor.fetchall()
    
    for site in sites:
        manager.sync_site_aps(site['site_id'])
        manager.create_site_config(site['site_id'])
    
    cursor.close()
    manager.db.close()