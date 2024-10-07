#!/bin/bash

# Variables
VSFTPD_CONF="/etc/vsftpd/vsftpd.conf"
FIREWALL_PORTS=(20 21)
PACKAGES=("vsftpd" "ftp")
CONFIG_LINES=("anonymous_enable=NO" "local_enable=YES" "write_enable=YES" "chroot_local_user=YES")

# Function to check and install packages in a loop
check_and_install_packages() {
    echo "Checking and Installing required packages..."
    for package in "${PACKAGES[@]}"; do
        if rpm -q "$package" > /dev/null 2>&1; then
            echo "$package is already installed."
        else
            echo "$package is not installed. Installing..."
            sudo yum install -y "$package"
        fi
    done
}

# Function to check and add configuration lines in a loop
check_and_add_config_lines() {
    echo "Checking and updating VSFTPD configuration..."
    for line in "${CONFIG_LINES[@]}"; do
        if grep -q "^$line" "$VSFTPD_CONF"; then
            echo "Line '$line' already exists in $VSFTPD_CONF."
        else
            echo "Adding '$line' to $VSFTPD_CONF."
            echo "$line" | sudo tee -a "$VSFTPD_CONF"
        fi
    done
}

# Function to check and open firewall ports in a loop
check_and_open_firewall_ports() {
    echo "Configuring firewall for FTP ports..."
    for port in "${FIREWALL_PORTS[@]}"; do
        if sudo firewall-cmd --list-ports | grep -q "${port}/tcp"; then
            echo "Firewall port $port/tcp is already open."
        else
            echo "Opening firewall port $port/tcp."
            sudo firewall-cmd --permanent --add-port="${port}/tcp"
        fi
    done
    sudo firewall-cmd --reload
}

# Function to set up VSFTPD service
setup_vsftpd() {
    # Install required packages
    check_and_install_packages

    # Enable and start the VSFTPD service
    echo "Enabling and starting VSFTPD service..."
    sudo systemctl enable vsftpd.service
    sudo systemctl start vsftpd.service

    # Check VSFTPD service status
    echo "Checking VSFTPD service status..."
    sudo systemctl status vsftpd.service
}

# Function to configure VSFTPD
configure_vsftpd() {
    # Check and add configuration lines to vsftpd.conf
    check_and_add_config_lines

    # Restart VSFTPD to apply the configuration
    echo "Restarting VSFTPD service..."
    sudo systemctl restart vsftpd.service
}

# Function to test FTP connectivity and create a test file
test_ftp_connectivity() {
    echo "Testing FTP connection..."
    sudo ftp localhost

    echo "Checking FTP directory /var/ftp..."
    cd /var/ftp/ && ls -l

    echo "Creating a test file in /var/ftp/pub..."
    cd /var/ftp/pub/ && sudo seq 10000 > 100k.txt && ls -l 100k.txt

    echo "Testing FTP access from localhost..."
    ftp localhost
}

# Main function to control the flow of the script
main() {
    # Setup VSFTPD (install packages, start service, check status)
    setup_vsftpd

    # Configure firewall for FTP ports
    check_and_open_firewall_ports

    # Configure and update VSFTPD
    configure_vsftpd

    # Test FTP connectivity and create test file
    test_ftp_connectivity

    echo "VSFTPD setup completed!"
}

# Call the main function
main
