#Medium Example (Check if a file exists and if it’s readable)
#!/bin/bash

# Medium example: Check if a file exists and whether it is readable

file="/etc/hosts"  # Specify the file to check

if [ -e "$file" ]; then  # Check if the file exists
    echo "$file exists."  # If true, print that the file exists
    if [ -r "$file" ]; then  # Check if the file is readable
        echo "$file is readable."  # If true, print that the file is readable
    else
        echo "$file is not readable."  # If false, print that the file is not readable
    fi
elif [ ! -e "$file" ]; then  # Check if the file does not exist
    echo "$file does not exist."  # If true, print that the file does not exist
else
    echo "Unknown error."  # If neither condition is met, print an error message
fi  # End of the if-elif-else structure