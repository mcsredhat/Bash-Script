#Advanced Example (Check if a file is executable and its size)

#!/bin/bash

# Advanced example: Check if a file is executable and if its size is greater than 0 bytes

file="/usr/bin/bash"  # Specify the file to check (an executable binary in this case)

if [ -e "$file" ]; then  # Check if the file exists
    echo "$file exists."  # If true, print that the file exists
    if [ -x "$file" ]; then  # Check if the file is executable using the -x test
        echo "$file is executable."  # If true, print that the file is executable
    else
        echo "$file is not executable."  # If false, print that the file is not executable
    fi

    if [ -s "$file" ]; then  # Check if the file is not empty (greater than 0 bytes) using the -s test
        echo "$file has a size greater than 0 bytes."  # If true, print that the file is not empty
    else
        echo "$file is empty."  # If false, print that the file is empty
    fi
else
    echo "$file does not exist."  # If the file doesn't exist, print this message
fi  # End of the if-else structure