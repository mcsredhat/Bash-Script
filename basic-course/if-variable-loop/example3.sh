### 3. (Validate and add multiple sections of configurations)


#!/bin/bash

# Define the file to modify
file_to_check="/etc/named.conf"  # Variable that stores the path to the file

# Define the lines for a complete section to be added
lines_to_add=(
    "# DNS forwarding settings"  # Comment indicating the start of DNS forwarding settings
    "forwarders {"  # Opening block for DNS forwarders
    "    8.8.8.8;"  # Google's public DNS server 1
    "    8.8.4.4;"  # Google's public DNS server 2
    "};"  # Closing block for DNS forwarders
    "# End of DNS forwarding settings"  # Comment indicating the end of DNS forwarding settings
)

# A flag to track if any lines are missing
lines_missing=false  # Initialize a flag variable to false (indicating no lines are missing initially)

# Loop through each line and check if it exists in the file
for line in "${lines_to_add[@]}"; do
    if ! grep -Fxq "$line" "$file_to_check"; then  # Check if the line is missing in the file
        echo "Missing line: '$line'"  # Inform the user which line is missing
        lines_missing=true  # Set the flag to true if a line is missing
    fi
done  # End of the loop

# If any lines are missing, add the entire section
if [ "$lines_missing" = true ]; then  # Check if any line was missing by evaluating the flag
    echo "Adding missing configuration to $file_to_check"  # Inform the user that the section will be added
    for line in "${lines_to_add[@]}"; do  # Loop through each line again to add them
        echo "$line" | sudo tee -a "$file_to_check" > /dev/null  # Append each line to the file
    done
else
    echo "All lines are already present in $file_to_check"  # Inform the user that all lines are already present
fi  # End of the if-else block
