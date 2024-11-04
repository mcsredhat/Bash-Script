#!/bin/bash

### Global Variable Definitions ###
PRIMARY_IP=$(hostname -I | awk '{print $1}')
ZONE_FILE="/var/named/linuxcbt.internal"
NAMED_CONF="/etc/named.conf"
NAMED_SERVICE="named.service"

# Array of DNS queries to perform
DNS_QUERIES=("ftp.linuxcbt.internal" "sftp.linuxcbt.internal")

# Array of CNAME records to add
CNAME_RECORDS=(
    "sftp IN CNAME linuxcbtserv2.linuxcbt.internal."
    "mail IN CNAME linuxcbtserv2.linuxcbt.internal."
)

### Function Definitions ###

# Function to check if a command executed successfully
check_status() {
    if [ $? -ne 0 ]; then
        echo "Error executing: $1"
        exit 1
    fi
}

# Function to add NS record if it doesn't already exist
add_ns_record() {
    local ns_entry="@ IN NS linuxcbtserv1.linuxcbt.internal."
    if grep -q "$ns_entry" "$ZONE_FILE"; then
        echo "$ZONE_FILE already contains NS entry for linuxcbtserv1."
    else
        echo "$ns_entry" >> "$ZONE_FILE"
        echo "NS record added to $ZONE_FILE."
    fi
}

# Function to configure secondary zone in named.conf
configure_secondary_zone() {
    if grep -q 'zone "linuxcbt.external"' "$NAMED_CONF"; then
        echo "Zone 'linuxcbt.external' already exists in $NAMED_CONF."
    else
        # Backup the current named.conf
        cp "$NAMED_CONF" "$NAMED_CONF.bak"
        cat << EOF >> "$NAMED_CONF"

zone "linuxcbt.external" IN {
    type slave;
    masters { $PRIMARY_IP; };
};
EOF
        echo "Slave zone for 'linuxcbt.external' added to $NAMED_CONF."
    fi
}

# Function to restart named service
restart_named_service() {
    echo "Restarting '$NAMED_SERVICE' service on linuxcbtserv2..."
    systemctl restart "$NAMED_SERVICE"
    check_status "systemctl restart $NAMED_SERVICE"
}

# Function to query DNS records
query_dns_records() {
    for query in "${DNS_QUERIES[@]}"; do
        echo "Querying localhost for '$query'..."
        dig @localhost "$query"
    done
}

# Function to add CNAME records if they don't already exist
add_cname_records() {
    for cname in "${CNAME_RECORDS[@]}"; do
        cname_name=$(echo "$cname" | awk '{print $1}')
        if grep -q "$cname_name IN CNAME" "$ZONE_FILE"; then
            echo "'$cname_name' CNAME record already exists in $ZONE_FILE."
        else
            echo "$cname" >> "$ZONE_FILE"
            echo "CNAME record added for '$cname_name'."
        fi
    done
}

# Main function to run all steps in sequence
main() {
    echo "Starting DNS configuration script..."

    # Step 1: Configure the NS record in the zone file
    echo "Configuring NS record in $ZONE_FILE for linuxcbtserv2..."
    add_ns_record

    # Step 2: Configure secondary zone in named.conf
    echo "Configuring $NAMED_CONF for 'linuxcbt.external'..."
    configure_secondary_zone

    # Step 3: Restart the named service
    restart_named_service

    # Step 4: Check the named service logs for errors
    echo "Checking the named service logs for errors..."
    tail -n 20 /var/named/data/named.run

    # Step 5: Query the specified DNS records
    echo "Performing DNS queries..."
    query_dns_records

    # Step 6: Add CNAME records to the zone file
    echo "Adding CNAME records to $ZONE_FILE..."
    add_cname_records

    # Step 7: Restart the named service after modifying CNAME records
    restart_named_service

    # Step 8: Query CNAME records to verify
    echo "Querying CNAME records on localhost..."
    query_dns_records

    echo "Script execution completed successfully."
}

# Call the main function to execute the script
main
