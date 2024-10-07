#!/bin/bash

# Variables
USER_FILE="users.txt"               # Path to the file containing username:password entries
HOME_DIR_BASE="/home"               # Base home directory
SHELL="/bin/bash"                   # Default shell
SKEL_DIR="/etc/skel"                # Skeleton directory for new users

# Password policy variables
MIN_DAYS=7                          # Minimum days before password change is allowed
MAX_DAYS=120                        # Maximum password age before it expires
WARN_DAYS=5                         # Number of days before password expiration to warn the user
EXPIRE_DATE=$(date -d "+1 year" +%Y-%m-%d)  # Account expiration after one year

# Function to check if the user exists
check_user_exists() {
    local username=$1
    if grep -q "^$username:" /etc/passwd; then
        return 0  # User exists
    else
        return 1  # User does not exist
    fi
}

# Function to create a new user
create_user() {
    local username=$1
    local password=$2

    # Add the user with the specified options
    sudo useradd -m -d "$HOME_DIR_BASE/$username" -k "$SKEL_DIR" -s "$SHELL" "$username"

    # Check if the user was successfully added
    if [[ $? -eq 0 ]]; then
        # Set the user's password
        echo "$username:$password" | sudo chpasswd

        # Set the password expiration policy
        sudo chage -m $MIN_DAYS -M $MAX_DAYS -W $WARN_DAYS -E $EXPIRE_DATE "$username"

        echo "User '$username' added successfully with password policy set."
    else
        echo "Failed to add user '$username'."
    fi
}

# Function to process the user creation from file
process_user_file() {
    # Check if the user file exists
    if [[ ! -f "$USER_FILE" ]]; then
        echo "File $USER_FILE does not exist!"
        exit 1
    fi

    # Read user:password pairs from the file
    while IFS=: read -r username password; do
        if check_user_exists "$username"; then
            echo "User '$username' already exists. Skipping."
        else
            create_user "$username" "$password"
        fi
    done < "$USER_FILE"
}

# Main execution
process_user_file
echo "User creation process completed."
