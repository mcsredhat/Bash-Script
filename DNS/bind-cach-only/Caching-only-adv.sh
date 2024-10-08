#!/bin/bash

# Array of required packages to install
PACKAGES=("net-tools" "firewalld" "unbound" "bind" "bind-utils")

# Array of firewall ports to configure for DNS
FIREWALL_PORTS=(53)

# Array of lines to be added to /etc/named.conf
NAMED_CONF_LINES=(
    "listen-on port 53 { 127.0.0.1; };"
    "listen-on-v6 port 53 { ::1; };"
    "allow-query { any; };"
)

# Array of SELinux booleans to configure
SELINUX_BOOLS=("named_write_master_zones" "allow_httpd_mod_auth_ntlm_winbind" "allow_ypbind")

# Function to check if a package is installed
check_package_installed() {
    for package in "${PACKAGES[@]}"; do
        if ! rpm -qa | grep -qw "$package"; then
            echo "$package not installed. Installing..."
            sudo yum install -y "$package"
            check_status "yum install $package"
        else
            echo "$package is already installed."
        fi
    done
}

# Function to check command execution status
# This will exit if the previous command fails
check_status() {
    if [ $? -ne 0 ]; then
        echo "Error executing command: $1"
        exit 1
    fi
}

# Function to add a line to a configuration file if it doesn't already exist
add_line_if_not_exists() {
    local file="$1"       # First argument: file path
    shift                 # Shift arguments to access subsequent params
    local lines=("$@")    # Remaining arguments: array of lines to add

    for line in "${lines[@]}"; do
        # Check if the line already exists in the file
        if ! grep -qF "$line" "$file"; then
            echo "Adding line: $line to $file"
            echo "$line" | sudo tee -a "$file" > /dev/null  # Add line if not found
        else
            echo "Line already exists: $line"
        fi
    done
}

# Function to configure firewall to allow specified ports
configure_firewall() {
    for port in "${FIREWALL_PORTS[@]}"; do
        echo "Configuring firewall for TCP port $port..."
        sudo firewall-cmd --zone=public --add-port=${port}/tcp --permanent
        check_status "firewall-cmd --zone=public --add-port=${port}/tcp --permanent"
        
        # Add rule for iptables as well
        sudo iptables -I INPUT -p tcp -m tcp --dport "$port" -j ACCEPT
    done
    echo "Reloading firewall to apply changes..."
    sudo firewall-cmd --reload
    sudo service iptables save
    sudo service iptables restart
}

# Function to configure SELinux booleans for named and bind services
configure_selinux() {
    echo "Configuring SELinux booleans..."

    # Loop through each SELinux boolean and set it to 'on'
    for bool in "${SELINUX_BOOLS[@]}"; do
        echo "Setting SELinux boolean: $bool"
        sudo setsebool -P "$bool" on
        check_status "setsebool -P $bool on"
    done
}

# Function to configure named.conf settings
configure_named_conf() {
    named_conf="/etc/named.conf"

    echo "Configuring named.conf to listen on localhost only and allow queries from any IP..."
    
    # Add lines from the NAMED_CONF_LINES array to the named.conf file if they don't already exist
    add_line_if_not_exists "$named_conf" "${NAMED_CONF_LINES[@]}"

    # Restart named service to apply configuration changes
    echo "Restarting named service..."
    sudo systemctl restart named
    check_status "systemctl restart named"
}

# Main function to organize the flow
main() {
    echo "### Starting DNS Caching-Only Server Setup ###"

    # Step 1: Install required packages
    check_package_installed

    # Step 2: Configure firewall for DNS port 53
    configure_firewall

    # Step 3: Configure SELinux settings
    configure_selinux

    # Step 4: Configure named.conf
    configure_named_conf

    # Step 5: Query DNS server at localhost
    echo "Querying DNS server at localhost..."
    dig @localhost
    check_status "dig @localhost"

    # Step 6: Query DNS server for a specific domain
    echo "Querying DNS server for www.linuxcbt.com..."
    dig @localhost www.linuxcbt.com
    check_status "dig @localhost www.linuxcbt.com"

    # Step 7: Check open UDP and TCP port 53 using netstat
    echo "Checking open UDP port 53..."
    netstat -nul | grep 53

    echo "Checking open TCP port 53..."
    netstat -ntl | grep 53

    echo "### DNS Caching-Only Server Setup Completed Successfully ###"
}

# Execute the main function
main
