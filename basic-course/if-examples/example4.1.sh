# Medium Example (Check if a directory exists and if it's writable)
#!/bin/bash

# Medium example: Check if a directory exists and if it is writable

directory="/tmp/my_test_directory"  # Specify the directory to check

if [ -d "$directory" ]; then  # Check if the directory exists using the -d test
    echo "$directory exists."  # If true, print that the directory exists
    if [ -w "$directory" ]; then  # Check if the directory is writable using the -w test
        echo "$directory is writable."  # If true, print that the directory is writable
    else
        echo "$directory is not writable."  # If false, print that it's not writable
    fi
else
    echo "$directory does not exist. Creating it..."  # If the directory doesn't exist, print this message
    mkdir -p "$directory"  # Create the directory using mkdir
    echo "$directory created successfully."  # Print a success message after creating the directory
fi  # End of the if-else structure