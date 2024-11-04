#!/bin/bash

### Global Variable Definitions ###
REQUIRED_PACKAGES=("httpd" "mod_ssl" "openssl" "openssl-devel" "ca-certificates" "php" "php-cli" "php-mysqlnd" "php-gd" "php-xml" "php-mbstring" "php-curl" "php-zip" "php-soap")
SELINUX_SETTINGS=(
    "httpd_can_network_connect on"
    "httpd_execmem on"
    "httpd_use_nfs on"
    "httpd_read_user_content on"
    "httpd_can_network_relabel on"
    "httpd_enable_cgi on"
)
FIREWALL_RULES=(
    "--permanent --add-port=80/tcp"
    "--permanent --add-port=443/tcp"
    "--permanent --add-port=53/tcp"
    "--permanent --add-port=53/udp"
    "--permanent --add-service=http"
    "--permanent --add-service=https"
    "--permanent --add-service=dns"
)
HOSTS_ENTRIES=(
    "172.31.43.107 linuxcbtserv3.linuxcbt.internal linuxcbtserv3"
    "172.31.44.229 site1.linuxcbt.internal"
    "172.31.35.154 linuxcbtserv2.linuxcbt.internal linuxcbtserv2"
    "172.31.44.229 linuxcbtserv1.linuxcbt.internal linuxcbtserv1"
)
RESOLV_CONF_ENTRIES=(
    "search linuxcbt.internal"
    "nameserver 172.31.44.229"
    "nameserver 172.31.35.154"
    "nameserver 172.31.108.225"
)
PHP_TEST_CONTENT="<center>TESTING PHP PROCESSING</center>"

### Function Definitions ###

# Check if a command executed successfully
check_status() {
    if [ $? -ne 0 ]; then
        echo "Error executing: $1"
        exit 1
    fi
}

# Install required packages if not already installed
install_packages() {
    for package in "${REQUIRED_PACKAGES[@]}"; do
        if ! rpm -q "$package" &>/dev/null; then
            echo "Installing package: $package"
            sudo yum install -y "$package"
            check_status "yum install $package"
        else
            echo "Package $package is already installed."
        fi
    done
}

# Enable and start specified services
manage_service() {
    local service="$1"
    if ! systemctl is-enabled "$service" &>/dev/null; then
        echo "Enabling $service service."
        sudo systemctl enable "$service"
        check_status "systemctl enable $service"
    fi
    if ! systemctl is-active "$service" &>/dev/null; then
        echo "Starting $service service."
        sudo systemctl start "$service"
        check_status "systemctl start $service"
    fi
}

# Configure firewall rules if not already present
configure_firewall() {
    for rule in "${FIREWALL_RULES[@]}"; do
        if ! sudo firewall-cmd --list-all | grep -q "${rule#*--permanent }"; then
            echo "Applying firewall rule: $rule"
            sudo firewall-cmd $rule
            check_status "firewall-cmd $rule"
        else
            echo "Firewall rule already applied: $rule"
        fi
    done
    sudo firewall-cmd --reload
    check_status "firewall-cmd --reload"
}

# Configure SELinux booleans as specified
configure_selinux() {
    for setting in "${SELINUX_SETTINGS[@]}"; do
        local boolean=$(echo "$setting" | awk '{print $1}')
        local value=$(echo "$setting" | awk '{print $2}')
        if [ "$(getsebool $boolean | awk '{print $3}')" != "$value" ]; then
            echo "Setting SELinux boolean $boolean to $value"
            sudo setsebool -P "$boolean" "$value"
            check_status "setsebool -P $boolean $value"
        else
            echo "SELinux boolean $boolean is already set to $value"
        fi
    done
}

# Update /etc/hosts with required entries if they don't exist
update_hosts() {
    for entry in "${HOSTS_ENTRIES[@]}"; do
        if ! grep -q "$entry" /etc/hosts; then
            echo "Adding entry to /etc/hosts: $entry"
            echo "$entry" | sudo tee -a /etc/hosts
        else
            echo "Entry already exists in /etc/hosts: $entry"
        fi
    done
}

# Update /etc/resolv.conf with required DNS settings
update_resolv_conf() {
    for entry in "${RESOLV_CONF_ENTRIES[@]}"; do
        if ! grep -q "$entry" /etc/resolv.conf; then
            echo "Adding entry to /etc/resolv.conf: $entry"
            echo "$entry" | sudo tee -a /etc/resolv.conf
        else
            echo "Entry already exists in /etc/resolv.conf: $entry"
        fi
    done
}

# Create a PHP test file if it doesn't already exist
create_php_test_file() {
    local php_test_file="/var/www/html/index.php"
    if ! grep -q "$PHP_TEST_CONTENT" "$php_test_file" 2>/dev/null; then
        echo "Creating PHP test file at $php_test_file"
        echo "<?php echo '$PHP_TEST_CONTENT'; ?>" | sudo tee "$php_test_file"
    else
        echo "PHP test file already contains the test content."
    fi
}

### Main Function ###
main() {
    echo "Starting system configuration script..."

    # Step 1: Install Required Packages
    install_packages

    # Step 2: Enable and Start Services
    echo "Managing services: httpd, named, firewalld"
    manage_service "httpd"
    manage_service "named"
    manage_service "firewalld"

    # Step 3: Configure Firewall
    configure_firewall

    # Step 4: Configure SELinux Boolean Status
    configure_selinux

    # Step 5: Update /etc/hosts
    update_hosts

    # Step 6: Update /etc/resolv.conf
    update_resolv_conf

    # Step 7: Create PHP Test File
    create_php_test_file

    echo "System configuration script completed successfully."
}

# Execute the main function
main
