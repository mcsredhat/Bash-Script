#!/bin/bash

### BIND Primary Server Configuration (linuxcbtserv2) ###

# Variables
PRIMARY_SERVER_IP=$(hostname -I | awk '{print $1}')  # Automatically get the primary server's IP address
SECONDARY_SERVER_IP="172.31.24.206"  # Set the secondary server IP (change as necessary)
ZONE_FILE="linuxcbt.internal"  # Name of the zone file
ZONE_FILE_PATH="/var/named/$ZONE_FILE"  # Full path to the zone file
HOSTNAME=$(hostname)  # Get hostname of the server

# Function to check command execution status
check_status() {
    if [ $? -ne 0 ]; then  # Check if the last command failed
        echo "Error: $1"  # Print error message
        exit 1  # Exit with error code
    fi
}

# Function to install BIND
install_bind() {
    local bind_packages=("bind" "bind-utils")  # Array of packages to install
    echo "Installing BIND..."
    yum install -y "${bind_packages[@]}"  # Install BIND and its utilities
    check_status "BIND installation"  # Check if installation succeeded
}

# Function to backup named.conf
backup_named_conf() {
    echo "Backing up /etc/named.conf..."
    cp /etc/named.conf /etc/named.conf.backup  # Backup the named.conf file
    check_status "Backup of /etc/named.conf"  # Check if backup succeeded
}

# Function to add zone definition to named.conf
add_zone_definition() {
    local zone_lines=(
        "zone \"$ZONE_FILE\" IN {"
        "    type master;"
        "    file \"$ZONE_FILE_PATH\";"
        "    allow-update { none; };"
        "};"
    )
    
    if ! grep -q "zone \"$ZONE_FILE\"" /etc/named.conf; then  # Check if zone definition exists
        echo "Adding zone definition for $ZONE_FILE to /etc/named.conf..."
        for line in "${zone_lines[@]}"; do  # Loop through the zone lines array
            echo "$line" >> /etc/named.conf  # Append each line to named.conf
        done
    else
        echo "Zone definition already exists in /etc/named.conf."  # Inform if it exists
    fi
}

# Function to create the zone file if it doesn't exist
create_zone_file() {
    if [ ! -f "$ZONE_FILE_PATH" ]; then  # Check if the zone file doesn't exist
        echo "Creating new zone file: $ZONE_FILE_PATH"
        touch "$ZONE_FILE_PATH"  # Create the zone file
    else
        echo "Zone file $ZONE_FILE_PATH already exists."  # Inform if it exists
    fi
}

# Function to define required DNS records
define_zone_content() {
    echo "Defining required DNS records..."
    local zone_lines=(
        "\$TTL 60"
        "@   IN SOA  linuxcbt.internal. vdns-admin.linuxcbt.internal. ("
        "               2017121506  ; serial"
        "               1D          ; refresh"
        "               1H          ; retry"
        "               1W          ; expire"
        "               3H )        ; minimum"
        "@          IN NS   linuxcbtserv2.linuxcbt.internal."
        "@          IN NS   linuxcbtserv1.linuxcbt.internal."
        "@          IN MX 2 linuxcbtserv1.linuxcbt.internal."
        "linuxcbtserv2.linuxcbt.internal   IN A     $PRIMARY_SERVER_IP"
        "linuxcbtserv1   IN A      $SECONDARY_SERVER_IP"
    )

    # Loop through each line and add to the zone file if missing
    for line in "${zone_lines[@]}"; do
        if ! grep -Fxq "$line" "$ZONE_FILE_PATH"; then  # Check if the line is missing
            echo "Adding missing record: $line"
            echo "$line" >> "$ZONE_FILE_PATH"  # Append the line to the zone file
        else
            echo "Record already exists: $line"  # Inform if the line exists
        fi
    done
}

# Function to check BIND configuration
check_bind_configuration() {
    echo "Checking BIND configuration..."
    named-checkconf /etc/named.conf  # Validate BIND configuration
    check_status "named-checkconf"  # Check if validation succeeded
}

# Function to check zone file syntax
check_zone_file() {
    echo "Checking zone file syntax..."
    named-checkzone "$ZONE_FILE" "$ZONE_FILE_PATH"  # Validate zone file
    check_status "Zone file check"  # Check if validation succeeded
}

# Function to set ownership and permissions on zone file
set_ownership() {
    echo "Changing ownership of $ZONE_FILE_PATH..."
    chown root:named "$ZONE_FILE_PATH"  # Set ownership to root:named
    check_status "Changing ownership of zone file"  # Check if ownership change succeeded
}

# Function to restart BIND service
restart_bind_service() {
    echo "Restarting BIND service..."
    systemctl restart named  # Restart BIND service
    check_status "Restart BIND service"  # Check if restart succeeded
}

# Function to check running named processes
check_named_processes() {
    echo "Checking named processes..."
    ps -ef | grep -i named  # List running named processes
}

# Function to verify BIND is listening on correct ports
check_tcp_connections() {
    echo "Checking open TCP connections on port 53..."
    netstat -ant | grep -E "53"  # Check open TCP connections for DNS
}

# Function to view BIND logs for errors
view_logs() {
    echo "Viewing named logs..."
    tail /var/log/messages  # Display the last few lines of the BIND log
}

# Function to configure the firewall for DNS
configure_firewall() {
    local firewall_ports=("53/tcp" "53/udp")  # Array of ports to open
    echo "Configuring firewall for DNS..."
    
    for port in "${firewall_ports[@]}"; do  # Loop through the firewall ports array
        firewall-cmd --permanent --add-port="$port"  # Allow each port
    done
    firewall-cmd --reload  # Reload the firewall to apply changes
    check_status "Firewall configuration"  # Check if configuration succeeded
}

# Function to test DNS queries
test_dns_queries() {
    echo "Testing DNS queries..."
    dig @localhost "$HOSTNAME"  # Query local hostname
    dig @"$PRIMARY_SERVER_IP" "$ZONE_FILE" NS  # Query for NS records
    dig @localhost "$ZONE_FILE" MX  # Query for MX records
    dig @localhost "www.$ZONE_FILE"  # Query for www records
    dig @localhost "linuxcbtserv1.$ZONE_FILE"  # Query for the secondary server
}

# Main function to organize the flow
main() {
    echo "### Starting BIND Primary Server Configuration (linuxcbtserv2) ###"
    install_bind  # Step 1: Install BIND
    backup_named_conf  # Step 2: Backup named.conf
    add_zone_definition  # Step 3: Add zone definition
    create_zone_file  # Step 4: Create zone file
    define_zone_content  # Step 5: Define DNS records
    check_bind_configuration  # Step 6: Check BIND configuration
    check_zone_file  # Step 7: Check zone file syntax
    set_ownership  # Step 8: Set ownership and permissions
    restart_bind_service  # Step 9: Restart BIND
    check_named_processes  # Step 10: Check running named processes
    check_tcp_connections  # Step 11: Check open TCP connections
    view_logs  # Step 12: View BIND logs
    configure_firewall  # Step 13: Configure firewall
    test_dns_queries  # Step 14: Test DNS queries
    echo "### BIND Primary Server (linuxcbtserv2) configuration completed successfully ###"
}

# Execute the main function
main
