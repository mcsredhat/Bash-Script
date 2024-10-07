#!/bin/bash

# Variables
VSFTPD_CONF="/etc/vsftpd/vsftpd.conf"
VSFTPD_MOD_FILE="vsmod.txt"
FTP_USER="linuxcbt"
FIREWALL_PORTS=(20 21)
SEBOOLS=(
    "allow_ftpd_anon_write"
    "allow_ftpd_use_cifs"
    "allow_ftpd_use_nfs"
    "ftpd_connect_db"
    "httpd_enable_ftp_server"
    "tftp_anon_write"
)
SEBOOL_STATES=(on on on on on on)
FTP_PACKAGES=("vsftpd" "ftp" "lftp")

# Array containing vsftpd.conf settings
VSFTPD_SETTINGS=(
    "anonymous_enable=NO"
    "local_enable=YES"
    "write_enable=YES"
    "local_umask=022"
    "dirmessage_enable=YES"
    "xferlog_enable=YES"
    "connect_from_port_20=YES"
    "xferlog_std_format=YES"
    "dual_log_enable=YES"
    "allow_writeable_chroot=YES"
    "pam_service_name=vsftpd"
    "userlist_enable=NO"
    "tcp_wrappers=NO"
)

# Function to check if packages are installed and install them if not
check_packages_installed() {
    echo "Checking and installing necessary packages..."
    for package in "${FTP_PACKAGES[@]}"; do
        if rpm -q "$package" >/dev/null 2>&1; then
            echo "$package is already installed."
        else
            echo "$package is not installed. Installing..."
            sudo yum install -y "$package"
        fi
    done
}

# Function to configure SELinux booleans
configure_selinux_booleans() {
    echo "Configuring SELinux booleans for FTP..."
    for ((i = 0; i < ${#SEBOOLS[@]}; i++)); do
        sudo setsebool -P "${SEBOOLS[$i]}" "${SEBOOL_STATES[$i]}"
        echo "Set ${SEBOOLS[$i]} to ${SEBOOL_STATES[$i]}"
    done
}

# Function to configure firewall ports
configure_firewall_ports() {
    echo "Configuring firewall for FTP ports..."
    for port in "${FIREWALL_PORTS[@]}"; do
        sudo firewall-cmd --permanent --add-port=${port}/tcp
        sudo iptables -I INPUT -m tcp -p tcp --dport "$port" -j ACCEPT
        echo "Port $port configured for firewall."
    done
    sudo firewall-cmd --reload
    sudo service iptables save && sudo service iptables restart
}

# Function to enable and start VSFTPD service
enable_vsftpd_service() {
    echo "Enabling and starting VSFTPD service..."
    sudo systemctl enable vsftpd
    sudo systemctl start vsftpd
    sudo systemctl status vsftpd
}

# Function to append the current vsftpd.conf to vsmod.txt
backup_vsftpd_conf() {
    echo "Backing up VSFTPD configuration to $VSFTPD_MOD_FILE..."
    sudo cat "$VSFTPD_CONF" >> "$VSFTPD_MOD_FILE"
}

# Function to add settings to vsftpd.conf only if they don't already exist
add_vsftpd_settings() {
    echo "Configuring VSFTPD settings in $VSFTPD_CONF..."
    for setting in "${VSFTPD_SETTINGS[@]}"; do
        if grep -q "^$setting" "$VSFTPD_CONF"; then
            echo "Setting '$setting' already exists in $VSFTPD_CONF."
        else
            echo "Adding '$setting' to $VSFTPD_CONF."
            echo "$setting" | sudo tee -a "$VSFTPD_CONF"
        fi
    done
}

# Function to test FTP connection with a specific user
test_ftp_connection() {
    echo "Testing FTP connection with user $FTP_USER..."
    ftp -inv <<EOF
open localhost
user $FTP_USER password
pwd
ls
bye
EOF
}

# Main execution function
main() {
    echo "### VSFTPD Server Setup for Specific User ###"

    # Step 1: Check and install VSFTPD, FTP, and LFTP packages
    check_packages_installed

    # Step 2: Configure SELinux settings for FTP
    configure_selinux_booleans

    # Step 3: Configure firewall for FTP ports (20, 21)
    configure_firewall_ports

    # Step 4: Enable and start VSFTPD service
    enable_vsftpd_service

    # Step 5: Backup current vsftpd.conf to vsmod.txt
    backup_vsftpd_conf

    # Step 6: Add necessary configuration to vsftpd.conf if not already present
    add_vsftpd_settings

    # Step 7: Test FTP connection
    test_ftp_connection

    echo "VSFTPD server setup for user $FTP_USER completed."
}

# Execute the main function
main
