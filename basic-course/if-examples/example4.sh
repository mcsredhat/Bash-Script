#Simple Example (Check if a file exists and whether it’s a regular file)

#!/bin/bash

# Simple example: Check if a file exists and if it is a regular file

file="/etc/hosts"  # Define the file path to check

if [ -e "$file" ]; then  # Check if the file exists using the -e test
    echo "$file exists."  # If true, print that the file exists
    if [ -f "$file" ]; then  # Check if the file is a regular file using the -f test
        echo "$file is a regular file."  # If true, print that it is a regular file
    else
        echo "$file is not a regular file."  # If false, print that it's not a regular file
    fi
else
    echo "$file does not exist."  # If the file doesn't exist, print this message
fi  # End of the if-else structure