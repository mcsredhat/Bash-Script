### 2. (Add multiple configurations if missing, including comments)


#!/bin/bash

# Define the file to be modified
file_to_check="/etc/named.conf"  # Store the path of the file that will be modified

# Array of configurations to check/add
lines_to_add=(
    "# Setting up named configuration"  # Comment to indicate the start of the configuration block
    "options {"  # Opening block for configuration options
    "    directory \"/var/named\";"  # Directory setting for the named service
    "    allow-query { localhost; };"  # Allow queries only from localhost
    "};"  # Closing block for configuration options
    "# End of named configuration"  # Comment to indicate the end of the configuration block
)

# Loop through each line and add it to the file if it’s missing
for line in "${lines_to_add[@]}"; do
    if ! grep -Fxq "$line" "$file_to_check"; then  # Check if the line exists in the file
        echo "Adding configuration: '$line' to $file_to_check"  # Inform the user the line will be added
        echo "$line" | sudo tee -a "$file_to_check" > /dev/null  # Append the missing line to the file
    else
        echo "Configuration already exists: '$line'"  # Inform the user that the line already exists
    fi
done  # End of the loop