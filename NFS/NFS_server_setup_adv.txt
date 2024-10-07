#!/bin/bash

# Define variables
PROJECT_DIR="/projectx"
NFS_SERVER_IP="172.31.44.225"
PACKAGES=("nfs-utils")
FIREWALL_SERVICES=("nfs" "rpc-bind")
FIREWALL_PORTS=("2049/tcp" "111/tcp")
SEBOOL_VARS=(
  "allow_nfsd_anon_write on"
  "virt_use_nfs on"
  "xen_use_nfs on"
  "nfs_export_all_ro=1"
  "nfs_export_all_rw=1"
  "samba_share_nfs=1"
  "httpd_use_nfs=1"
  "use_nfs_home_dirs=1"
)

# Function to check and install required packages
check_and_install_packages() {
    for package in "${PACKAGES[@]}"; do
        if rpm -q "$package" >/dev/null 2>&1; then
            echo "$package is already installed."
        else
            echo "$package is not installed. Installing..."
            sudo yum install -y "$package"
        fi
    done
}

# Function to check if a directory exists and create it if not
check_and_create_directory() {
    local dir=$1
    if [ -d "$dir" ]; then
        echo "Directory $dir already exists."
    else
        echo "Directory $dir does not exist. Creating..."
        sudo mkdir -p "$dir"
        sudo chmod 777 "$dir"
    fi
}

# Function to check and update /etc/exports for NFS
check_and_update_exports() {
    local export_entry="$1 *(rw,sync,no_root_squash)"
    if grep -q "$export_entry" /etc/exports; then
        echo "$export_entry already exists in /etc/exports."
    else
        echo "Adding $export_entry to /etc/exports."
        echo "$export_entry" | sudo tee -a /etc/exports
    fi
}

# Function to open required firewall services and ports
configure_firewall() {
    # Open firewall services
    for service in "${FIREWALL_SERVICES[@]}"; do
        sudo firewall-cmd --permanent --add-service="$service"
    done

    # Open firewall ports
    for port in "${FIREWALL_PORTS[@]}"; do
        sudo firewall-cmd --permanent --add-port="$port"
    done

    # Reload firewall to apply changes
    sudo firewall-cmd --reload
}

# Function to configure SELinux settings
configure_selinux() {
    for bool_var in "${SEBOOL_VARS[@]}"; do
        local var_name=${bool_var%% *} # Get the boolean name
        local var_value=${bool_var##* } # Get the value (on/off)
        echo "Setting SELinux boolean: $var_name to $var_value"
        sudo setsebool -P "$var_name" "$var_value"
    done
}

# Function to start NFS services
start_nfs_services() {
    sudo systemctl enable nfs-server
    sudo systemctl start nfs-server
    sudo systemctl enable rpcbind
    sudo systemctl start rpcbind
}

# Function to export NFS directories
export_nfs_directories() {
    sudo exportfs -av
    echo "NFS directories exported."
}

# Main function to execute all tasks
main() {
    echo "Configuring NFS server on linuxcbtserv2 ($NFS_SERVER_IP)..."

    # Step 1: Install necessary packages
    check_and_install_packages

    # Step 2: Enable and start NFS services
    start_nfs_services

    # Step 3: Check and create /projectx directory
    check_and_create_directory "$PROJECT_DIR"

    # Step 4: Update /etc/exports with the directory configuration
    check_and_update_exports "$PROJECT_DIR"

    # Step 5: Export NFS directories
    export_nfs_directories

    # Step 6: Configure firewall for NFS and RPCBIND
    configure_firewall

    # Step 7: Display current NFS exports
    sudo showmount --exports "$NFS_SERVER_IP"

    # Step 8: Verify NFS and RPCBIND status
    echo "Verifying NFS and RPCBIND services..."
    sudo netstat -ntlp | grep -i 'nfs\|rpcbind'

    # Step 9: Configure SELinux for NFS
    configure_selinux

    echo "NFS server setup completed on linuxcbtserv2."
}

# Call the main function
main
