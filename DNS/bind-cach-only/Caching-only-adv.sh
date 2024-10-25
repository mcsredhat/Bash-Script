#!/bin/bash

# Define the configuration file path
CONFIG_FILE="/etc/named.conf"

# Array of required packages to install
PACKAGES=("net-tools" "firewalld" "unbound" "bind" "bind-utils")

# Define the configuration lines we want to ensure within the options block
NAMED_CONF_LINES=(
    "listen-on port 53 { 127.0.0.1; };"
    "listen-on-v6 port 53 { ::1; };"

)

# Function to check if each package is installed, and install if not
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
check_status() {
    if [ $? -ne 0 ]; then
        echo "Error executing command: $1"
        exit 1
    fi
}

# Function to add or replace lines specifically within the options block
add_or_replace_in_options_block() {
    # Ensure the options block exists
    if ! grep -q "^options\s*{" "$CONFIG_FILE"; then
        echo "No options block found in $CONFIG_FILE. Adding one."
        echo -e "options {\n};" | sudo tee -a "$CONFIG_FILE" > /dev/null
    fi

    
# Replace all instances of 'localhost' with 'any' in the options block
    echo "Replacing all instances of 'localhost' with 'any' in options block..."
    sudo sed -i "/^options\s*{/,/^};/s/localhost/any/g" "$CONFIG_FILE"


    # Add required lines to options block only if they are not present
    for line in "${NAMED_CONF_LINES[@]}"; do
        # Check if the line already exists
        if ! grep -qF "$line" "$CONFIG_FILE"; then
            echo "Adding line: $line within options block in $CONFIG_FILE"
            # Insert the line before the closing brace of the options block
            sudo sed -i "/^options\s*{/,/^};/s/^};/    $line\n};/" "$CONFIG_FILE"
        else
            echo "Line already exists in options block: $line"
        fi
    done
}


# Function to configure named.conf
configure_named_conf() {
    echo "Configuring named.conf with correct options..."

    for line in "${NAMED_CONF_LINES[@]}"; do
        add_or_replace_in_options_block "$line"
    done

    # Validate configuration
    if named-checkconf "$CONFIG_FILE"; then
        echo "Configuration is valid. Restarting named service..."
        sudo systemctl restart named
        check_status "systemctl restart named"
    else
        echo "Configuration validation failed. Please check $CONFIG_FILE."
        exit 1
    fi
}

# Main function
main() {
    echo "### Starting DNS Caching-Only Server Setup ###"

    # Step 1: Install required packages
    check_package_installed

    # Step 2: Configure named.conf
 configure_named_conf

    echo "### DNS Caching-Only Server Setup Completed Successfully ###"
}

# Execute the main function
main

