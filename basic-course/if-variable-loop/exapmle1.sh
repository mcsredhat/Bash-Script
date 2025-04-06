### 1. **Simple Example** (Add lines to a file if not already present)


#!/bin/bash

# Define the file to be modified
file_to_check="/etc/named.conf"  # This variable stores the path to the configuration file

# Define the lines to search for and add if missing
lines_to_add=(
    "options {"  # Opening configuration block
    "    directory \"/var/named\";"  # Directory setting for the named service
    "    listen-on port 53 { 127.0.0.1; };"  # Listen on port 53 for localhost
    "};"  # Closing configuration block
)

# Loop through each line in the lines_to_add array
for line in "${lines_to_add[@]}"; do
    # Check if the line is already in the file
    if ! grep -Fxq "$line" "$file_to_check"; then  # grep checks if the exact line is in the file (-F: fixed string, -x: whole line, -q: quiet mode)
        echo "Adding line: '$line' to $file_to_check"  # Inform the user that the line is missing and will be added
        echo "$line" | sudo tee -a "$file_to_check" > /dev/null  # Append the missing line to the file using tee with sudo, suppress output
    else
        echo "Line already exists: '$line'"  # If the line exists, inform the user
    fi
done  # End of the loop