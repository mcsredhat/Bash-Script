### **2. Medium Example**

#This example includes error handling, checks for missing lines, and supports multiple file sections.

#!/bin/bash

# Global variable for the file to modify
global_file="/etc/named.conf"  # Global variable that stores the file path

# Global array for the main configuration section
global_config_lines=(
    "# Main DNS configuration"
    "options {"
    "    directory \"/var/named\";"
    "    allow-query { localhost; };"
    "};"
)

# Local function to test if a file exists
check_file_exists() {
    local file="$1"  # Local variable for file path
    if [[ ! -f "$file" ]]; then  # Test if file does not exist
        echo "Error: File '$file' does not exist."  # Print error message
        exit 1  # Exit with error code 1
    fi
}

# Local function to add missing lines from an array to the file
add_missing_lines() {
    local file="$1"  # Local variable for file path
    local -n lines="$2"  # Reference the array passed in
    local missing=false  # Local flag for missing lines

    for line in "${lines[@]}"; do  # Loop through the array of lines
        if ! grep -Fxq "$line" "$file"; then  # Check if the line is missing
            echo "Missing line: '$line'"  # Inform which line is missing
            missing=true  # Set the missing flag to true
        fi
    done

    # If any lines were missing, add them
    if [ "$missing" = true ]; then  # Check if any lines are missing
        echo "Adding missing lines to $file"  # Inform user
        for line in "${lines[@]}"; do
            echo "$line" | sudo tee -a "$file" > /dev/null  # Add missing lines
        done
    else
        echo "All lines are already present."  # All lines exist
    fi
}

# Main function to control the script
main() {
    check_file_exists "$global_file"  # Call function to check file existence
    add_missing_lines "$global_file" global_config_lines  # Add missing lines
}

main  # Run the main function