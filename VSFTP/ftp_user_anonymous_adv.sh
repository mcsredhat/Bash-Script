#!/bin/bash

# Variables
VSFTPD_CONF="/etc/vsftpd/vsftpd.conf"
FTP_DIR="/var/ftp"
FTP_SERVER="localhost"
LFTP_SERVER="192.168.75.21"
FIREWALL_PORTS=(20 21)
VSFTPD_SETTINGS=(
    "anonymous_enable=YES"
    "local_enable=NO"
    "write_enable=YES"
    "local_umask=022"
    "anon_upload_enable=YES"
    "dirmessage_enable=YES"
    "xferlog_enable=YES"
    "connect_from_port_20=YES"
    "chown_uploads=YES"
    "chown_username=bin"
    "xferlog_std_format=YES"
    "listen=YES"
    "pam_service_name=vsftpd"
    "dual_log_enable=YES"
    "userlist_enable=NO"
    "tcp_wrappers=NO"
)

# Function to check and install vsftpd if not installed
check_and_install_vsftpd() {
    if ! rpm -qa | grep -qw vsftpd; then
        echo "VSFTPD not installed. Installing..."
        sudo yum install -y vsftpd
    else
        echo "VSFTPD is already installed."
    fi
}

# Function to update vsftpd.conf settings
update_vsftpd_conf() {
    echo "Configuring VSFTPD for anonymous access..."
    for setting in "${VSFTPD_SETTINGS[@]}"; do
        if ! grep -q "^$setting" "$VSFTPD_CONF"; then
            echo "Adding $setting to $VSFTPD_CONF"
            echo "$setting" | sudo tee -a "$VSFTPD_CONF"
        else
            echo "$setting already exists in $VSFTPD_CONF"
        fi
    done
}

# Function to configure SELinux settings
configure_selinux() {
    echo "Configuring SELinux for FTP..."
    sudo setsebool -P allow_ftpd_anon_write on
    sudo chcon -Rvt public_content_rw_t "$FTP_DIR"
    sudo semanage fcontext -a -t public_content_rw_t "$FTP_DIR"
    echo "SELinux configured for anonymous FTP write access."
}

# Function to configure firewall
configure_firewall() {
    echo "Configuring firewall for FTP ports..."
    for port in "${FIREWALL_PORTS[@]}"; do
        sudo firewall-cmd --permanent --add-port=${port}/tcp
        sudo iptables -I INPUT -p tcp -m tcp --dport "$port" -j ACCEPT
    done
    sudo firewall-cmd --reload
    sudo service iptables save
    sudo service iptables restart
    echo "Firewall configuration complete."
}

# Function to restart vsftpd service
restart_vsftpd_service() {
    echo "Restarting VSFTPD service..."
    sudo systemctl restart vsftpd.service
    sudo systemctl status vsftpd.service
}

# Function to test FTP connection locally
test_ftp_connection() {
    echo "Testing FTP connection to $FTP_SERVER..."
    ftp -inv <<EOF
open $FTP_SERVER
user anonymous
pwd
ls
bye
EOF
}

# Function to test FTP connection using lftp
test_lftp_connection() {
    echo "Testing FTP connection to $LFTP_SERVER with lftp..."
    lftp "$LFTP_SERVER" -u anonymous
}

# Main execution
main() {
    echo "### VSFTPD Anonymous FTP Setup ###"

    # Step 1: Check and install VSFTPD
    check_and_install_vsftpd

    # Step 2: Update vsftpd.conf with necessary settings for anonymous FTP
    update_vsftpd_conf

    # Step 3: Configure SELinux for FTP access
    configure_selinux

    # Step 4: Configure firewall for FTP ports (20 and 21)
    configure_firewall

    # Step 5: Restart VSFTPD service
    restart_vsftpd_service

    # Step 6: Test FTP connection locally
    test_ftp_connection

    # Step 7: Optionally, test FTP connection to another server using lftp
    test_lftp_connection

    echo "VSFTPD anonymous FTP setup completed."
}

# Execute the main function
main
