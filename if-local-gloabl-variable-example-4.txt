
### **Advanced Bash Script Example with Arrays, Local/Global Variables, Lists**


#!/bin/bash

# Global variable that defines the file we want to modify
global_file_to_check="/etc/named.conf"  # Global variable holding the file path

# Global array that defines the lines to search for and add if missing
global_lines_to_add=(
    "# DNS forwarding settings"  # Comment indicating start of DNS forwarding settings
    "forwarders {"  # Opening block for DNS forwarders
    "    8.8.8.8;"  # Google's public DNS server 1
    "    8.8.4.4;"  # Google's public DNS server 2
    "};"  # Closing block for DNS forwarders
    "# End of DNS forwarding settings"  # Comment indicating end of DNS forwarding settings
)

# Function to check if lines are missing and add them if necessary
add_lines_if_missing() {
    local file="$1"  # Local variable to hold the file name passed as an argument
    local -n lines_list="$2"  # Local reference to an array (lines to check/add)
    local missing_flag=false  # Local variable flag to track if any line is missing

    # Loop through each line in the lines_list array
    for line in "${lines_list[@]}"; do
        # Check if the line exists in the file
        if ! grep -Fxq "$line" "$file"; then  # If the line is missing (-F: fixed string, -x: whole line, -q: quiet)
            echo "Line missing: '$line'"  # Output which line is missing
            missing_flag=true  # Set the flag to true to indicate a missing line
        fi
    done

    # If any lines were missing, add the entire block of lines to the file
    if [ "$missing_flag" = true ]; then  # Check if the flag is set to true (indicating missing lines)
        echo "Adding missing lines to $file"  # Inform the user that lines will be added
        for line in "${lines_list[@]}"; do  # Loop through the array again to add the lines
            echo "$line" | sudo tee -a "$file" > /dev/null  # Append the missing lines to the file using tee
        done
    else
        echo "All lines are already present in $file"  # Inform the user that all lines are already present
    fi
}

# Main function that controls the script's flow
main() {
    # Example of a local array defined within the main function (could be for additional configurations)
    local local_additional_lines=(
        "# Local configuration section"  # Comment indicating start of additional configuration
        "logging {"  # Opening block for logging configuration
        "    channel default_debug {"  # Specify logging channel
        "        file \"/var/named/data/named.run\";"  # Log file location
        "        severity dynamic;"  # Set logging severity
        "    };"  # Close logging channel
        "};"  # Close logging configuration block
        "# End of local configuration"  # Comment indicating end of additional configuration
    )

    # Call the function to check and add lines using global variables
    add_lines_if_missing "$global_file_to_check" global_lines_to_add  # Passing global file and lines array

    # Call the function again with local array (optional additional lines to be added)
    add_lines_if_missing "$global_file_to_check" local_additional_lines  # Passing global file and local array
}

# Execute the main function
main  # Start the main script execution
```

