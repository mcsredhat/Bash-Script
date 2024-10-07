#!/bin/bash

# Define variables
NFS_SERVER_IP="172.31.44.225"
NFS_SERVER_HOSTNAME="linuxcbtserv2.linuxcbt.internal"
PROJECT_DIR="/projectx"
MOUNT_ENTRY="$NFS_SERVER_HOSTNAME:$PROJECT_DIR $PROJECT_DIR nfs defaults 0 0"
FILES_TO_APPEND=("100k.txt" "1m.txt")

# Function to check if a package is installed
check_and_install_packages() {
    local packages=("$@")
    for package in "${packages[@]}"; do
        if rpm -q "$package" >/dev/null 2>&1; then
            echo "$package is already installed."
        else
            echo "$package is not installed. Installing..."
            sudo yum install -y "$package"
        fi
    done
}

# Function to check if the NFS share is mounted
check_and_mount_nfs() {
    if mount | grep -q "$PROJECT_DIR"; then
        echo "$PROJECT_DIR is already mounted."
    else
        echo "Mounting NFS share..."
        sudo mount -t nfs "$NFS_SERVER_HOSTNAME:$PROJECT_DIR" "$PROJECT_DIR"
    fi
}

# Function to append data to files in the NFS directory
append_data_to_files() {
    for file in "${FILES_TO_APPEND[@]}"; do
        echo "Appending data to $file..."
        sudo seq 10000 >> "$PROJECT_DIR/$file"
        sudo ls -l "$PROJECT_DIR/$file"
    done
}

# Function to configure /etc/hosts and /etc/fstab
configure_hosts_and_fstab() {
    # Add NFS server entry to /etc/hosts if not present
    if ! grep -q "$NFS_SERVER_IP" /etc/hosts; then
        echo "$NFS_SERVER_IP $NFS_SERVER_HOSTNAME linuxcbtserv2" | sudo tee -a /etc/hosts
    else
        echo "/etc/hosts already contains an entry for $NFS_SERVER_IP."
    fi

    # Add NFS mount to /etc/fstab for persistence
    if ! grep -q "$MOUNT_ENTRY" /etc/fstab; then
        echo "Adding NFS mount to /etc/fstab."
        echo "$MOUNT_ENTRY" | sudo tee -a /etc/fstab
    else
        echo "/etc/fstab already has a persistent mount for $PROJECT_DIR."
    fi
}

# Function to start and enable rpcbind service
start_rpcbind_service() {
    sudo systemctl start rpcbind
    sudo systemctl enable rpcbind
}

# Main function to control the flow of the script
main() {
    echo "Configuring NFS client on linuxcbtserv1..."

    # Step 1: Check and install required packages
    check_and_install_packages "nfs-utils"

    # Step 2: Start and enable rpcbind service
    start_rpcbind_service

    # Step 3: Configure /etc/hosts and /etc/fstab
    configure_hosts_and_fstab

    # Step 4: Mount the NFS share if not already mounted
    check_and_mount_nfs

    # Step 5: Verify mounted file systems
    mount | grep "$PROJECT_DIR"

    # Step 6: Check disk space on the mounted NFS directory
    sudo df -h "$PROJECT_DIR"

    # Step 7: Append data to files in the NFS-mounted directory
    append_data_to_files

    # Step 8: Remount all filesystems listed in /etc/fstab
    sudo mount -a

    # Step 9: Query NFS shares from the NFS server
    sudo showmount --all "$NFS_SERVER_IP"

    echo "NFS client setup completed on linuxcbtserv1."
}

# Call the main function
main
