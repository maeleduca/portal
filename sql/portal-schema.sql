-- Portal Database Schema

-- User profiles
CREATE TABLE IF NOT EXISTS user_profiles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(255) NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    cpf VARCHAR(14) UNIQUE NOT NULL,
    phone VARCHAR(20),
    email VARCHAR(255) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_username (username),
    INDEX idx_email (email),
    INDEX idx_cpf (cpf)
);

-- Admin users
CREATE TABLE IF NOT EXISTS admin_users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(255) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    is_super_admin BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP NULL,
    INDEX idx_username (username),
    INDEX idx_email (email)
);

-- UniFi Sites
CREATE TABLE IF NOT EXISTS unifi_sites (
    id INT AUTO_INCREMENT PRIMARY KEY,
    site_name VARCHAR(255) NOT NULL,
    site_description TEXT,
    site_id VARCHAR(255) UNIQUE NOT NULL,
    enabled BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_site_id (site_id)
);

-- Admin Site Access
CREATE TABLE IF NOT EXISTS admin_site_access (
    id INT AUTO_INCREMENT PRIMARY KEY,
    admin_id INT NOT NULL,
    site_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (admin_id) REFERENCES admin_users(id) ON DELETE CASCADE,
    FOREIGN KEY (site_id) REFERENCES unifi_sites(id) ON DELETE CASCADE,
    UNIQUE KEY unique_admin_site (admin_id, site_id)
);

-- Access points configuration
CREATE TABLE IF NOT EXISTS ap_config (
    id INT AUTO_INCREMENT PRIMARY KEY,
    site_id INT NOT NULL,
    ap_name VARCHAR(255) NOT NULL,
    ap_mac VARCHAR(17) NOT NULL,
    location VARCHAR(255),
    ssid VARCHAR(32) NOT NULL,
    vlan_id INT,
    enabled BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (site_id) REFERENCES unifi_sites(id) ON DELETE CASCADE,
    UNIQUE KEY unique_ap_site (ap_mac, site_id),
    INDEX idx_ap_mac (ap_mac),
    INDEX idx_ssid (ssid)
);

-- System settings
CREATE TABLE IF NOT EXISTS system_settings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    site_id INT,
    setting_key VARCHAR(255) NOT NULL,
    setting_value TEXT,
    description TEXT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    updated_by INT,
    FOREIGN KEY (site_id) REFERENCES unifi_sites(id) ON DELETE CASCADE,
    UNIQUE KEY unique_setting_site (setting_key, site_id),
    INDEX idx_setting_key (setting_key)
);