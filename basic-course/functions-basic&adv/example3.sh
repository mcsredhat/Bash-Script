### **3. Advanced Example**

#This advanced script handles multiple configurations, has local and global variables, and checks for multiple sections to be added.

#!/bin/bash

# Global variables for file paths
global_file="/etc/named.conf"  # Global variable to store the file path

# Global arrays for different configuration sections
global_main_config=(
    "# Main DNS configuration"
    "options {"
    "    directory \"/var/named\";"
    "    allow-query { localhost; };"
    "};"
)

global_forwarders_config=(
    "# Forwarders configuration"
    "forwarders {"
    "    8.8.8.8;"
    "    8.8.4.4;"
    "};"
)

# Function to check if file exists
check_file_exists() {
    local file="$1"  # Local variable for file path
    if [[ ! -f "$file" ]]; then  # Test if file does not exist
        echo "Error: File '$file' does not exist."  # Print error message
        exit 1  # Exit with error code 1
    fi
}

# Function to add missing lines
add_missing_lines() {
    local file="$1"  # Local variable for file path
    local -n lines="$2"  # Reference to array passed
    local section="$3"  # Local variable for section name

    local missing=false  # Local flag to track if any lines are missing
    echo "Checking $section configuration..."  # Inform user about the section being checked

    for line in "${lines[@]}"; do  # Loop through the array of lines
        if ! grep -Fxq "$line" "$file"; then  # If line is missing
            echo "Line missing: '$line'"  # Inform user about the missing line
            missing=true  # Set the missing flag to true
        fi
    done

    if [ "$missing" = true ]; then  # If any lines were missing
        echo "Adding missing $section configuration..."  # Inform user
        for line in "${lines[@]}"; do  # Loop through again to add lines
            echo "$line" | sudo tee -a "$file" > /dev/null  # Append lines to file
        done
    else
        echo "$section configuration is already present."  # Inform user
    fi
}

# Main function to manage the script execution
main() {
    check_file_exists "$global_file"  # Call function to check if file exists

    # Add multiple sections by calling the add_missing_lines function with different arrays
    add_missing_lines "$global_file" global_main_config "Main"
    add_missing_lines "$global_file" global_forwarders_config "Forwarders"
}

main  # Execute the main function
