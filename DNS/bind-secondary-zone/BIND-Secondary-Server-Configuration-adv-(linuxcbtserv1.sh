#!/bin/bash

### BIND Secondary Server Configuration (linuxcbtserv1) ###

# Variables
PRIMARY_SERVER_IP="172.31.19.202"  # Set the primary server IP (linuxcbtserv2)
SECONDARY_SERVER_IP=$(hostname -I | awk '{print $1}')  # Automatically get secondary server's IP
ZONE_FILE="linuxcbt.external"  # Name of the zone file
ZONE_FILE_PATH="/var/named/$ZONE_FILE"  # Full path to the zone file
HOSTNAME=$(hostname)  # Get hostname of the server

# Function to check command execution status
check_status() {
    if [ $? -ne 0 ]; then  # Check if the last command executed successfully
        echo "Error: $1"  # Print error message if it failed
        exit 1  # Exit the script with an error code
    fi
}

# Function to check and add lines in named.conf
check_and_add_named_conf_lines() {
    local lines=("zone \"$ZONE_FILE\" IN {"
                 "    type slave;"
                 "    masters { $PRIMARY_SERVER_IP; };"
                 "    file \"$ZONE_FILE_PATH\";"
                 "};")  # Array of lines to check

    # Loop through each line in the array
    for line in "${lines[@]}"; do
        if ! grep -qF "$line" /etc/named.conf; then  # Check if the line is not already present
            echo "Adding line to /etc/named.conf: $line"
            echo "$line" >> /etc/named.conf  # Add the line to the named.conf file
        else
            echo "Line already exists in /etc/named.conf: $line"  # Inform if the line exists
        fi
    done
}

# Function to check and add DNS records in the zone file
check_and_add_zone_lines() {
    # Define the zone lines as an array
    local zone_lines=(
        "\$TTL 60" 
        "@   IN SOA  linuxcbt.external. vdns-admin.linuxcbt.external. ("
        "               2017121506  ; serial"
        "               1D          ; refresh"
        "               1H          ; retry"
        "               1W          ; expire"
        "               3H )        ; minimum"
        "@          IN NS    linuxcbtserv2.linuxcbt.external."
        "@          IN NS    linuxcbtserv1.linuxcbt.external."
        "@          IN MX 2  linuxcbtserv1.linuxcbt.external."
        ""
        "linuxcbtserv2   IN A     $PRIMARY_SERVER_IP"
        "linuxcbtserv1   IN A     $SECONDARY_SERVER_IP"
        "www             IN CNAME linuxcbtserv2.linuxcbt.external."
    )

    # Loop through each line in the zone_lines array
    for line in "${zone_lines[@]}"; do
        if ! grep -Fxq "$line" "$ZONE_FILE_PATH"; then  # Check if the line is not already present
            echo "Adding line to zone file: $line"
            echo "$line" >> "$ZONE_FILE_PATH"  # Add the line to the zone file
        else
            echo "Line already exists in zone file: $line"  # Inform if the line exists
        fi
    done
}

# Function to set permissions and check configuration
set_permissions_and_check() {
    echo "Changing ownership of $ZONE_FILE_PATH..."
    chown root:named "$ZONE_FILE_PATH"  # Set ownership to root:named
    check_status "Changing ownership of zone file"  # Check status

    echo "Checking BIND configuration..."
    named-checkconf /etc/named.conf  # Validate BIND configuration
    check_status "named-checkconf"  # Check status
}

# Function to restart BIND service
restart_bind() {
    echo "Restarting BIND service..."
    systemctl restart named  # Restart BIND service
    check_status "Restart BIND service"  # Check status
}

# Function to check running named processes
check_named_processes() {
    echo "Checking named processes..."
    ps -ef | grep -i named  # List running named processes
}

# Function to verify BIND is listening on correct ports
check_tcp_connections() {
    echo "Checking open TCP connections on port 53..."
    netstat -ant | grep 53  # Check open TCP connections for DNS
}

# Function to view BIND logs for errors
view_logs() {
    echo "Viewing named logs..."
    tail /var/log/messages  # Display the last few lines of the BIND log
}

# Function to test DNS queries
test_dns_queries() {
    echo "Testing DNS queries..."
    dig @localhost "$HOSTNAME"  # Query local hostname
    dig @"$SECONDARY_SERVER_IP" "$ZONE_FILE" NS  # Query for NS records
    dig @localhost "www.$ZONE_FILE"  # Query for www records
    dig @"$SECONDARY_SERVER_IP" "linuxcbtserv2.$ZONE_FILE"  # Query for the secondary server
}

# Main function to organize the flow
main() {
    echo "### Starting BIND Secondary Server Configuration (linuxcbtserv1) ###"

    # Step 1: Check and add lines in named.conf
    check_and_add_named_conf_lines

    # Step 2: Check and create the zone file if it doesn't exist
    if [ ! -f "$ZONE_FILE_PATH" ]; then  # Check if the zone file does not exist
        echo "Creating new zone file: $ZONE_FILE_PATH"
        cp /var/named/named.localhost "$ZONE_FILE_PATH"  # Copy the localhost zone file as a template
    fi

    # Step 3: Check and add DNS records in the zone file
    check_and_add_zone_lines

    # Step 4: Set permissions and check BIND configuration
    set_permissions_and_check

    # Step 5: Restart BIND service
    restart_bind

    # Step 6: Check running named processes
    check_named_processes

    # Step 7: Verify open TCP connections
    check_tcp_connections

    # Step 8: View BIND logs
    view_logs

    # Step 9: Test DNS queries
    test_dns_queries

    echo "### BIND Secondary Server (linuxcbtserv1) configuration completed successfully ###"
}

# Execute the main function
main
