### **1. Simple Example**

#This script checks if a line exists in a file and adds it if it’s missing, using local/global variables and functions.


#!/bin/bash

# Global variable for the file to modify
global_file="/etc/named.conf"  # Define the file we want to check and modify

# Global array to hold the lines to check/add
global_lines=("options {"
              "    directory \"/var/named\";"
              "    listen-on port 53 { 127.0.0.1; };"
              "};")

# Function to add lines to the file if they are missing
add_lines_if_missing() {
    local file="$1"  # Local variable holding the file path
    local -n lines_list="$2"  # Local reference to the array of lines to add
    for line in "${lines_list[@]}"; do  # Loop through each line in the array
        if ! grep -Fxq "$line" "$file"; then  # Check if the line exists in the file
            echo "$line" | sudo tee -a "$file" > /dev/null  # Add line to file if not found
        fi
    done
}

# Function to test if the file exists before proceeding
check_file_exists() {
    local file="$1"  # Local variable holding the file path
    if [[ ! -f "$file" ]]; then  # If the file does not exist
        echo "Error: File '$file' does not exist."  # Output error message
        exit 1  # Exit with error code 1
    fi
}

# Main function that controls the script
main() {
    check_file_exists "$global_file"  # Check if the file exists before proceeding
    add_lines_if_missing "$global_file" global_lines  # Add missing lines to the file
    echo "Script completed successfully."  # Output success message
}

main  # Execute the main function