#Advanced Example (Check user input, validate it, and perform a task)

#!/bin/bash

# Advanced example: Check user input for a number, validate the range, and perform a task

read -p "Enter a number between 1 and 10: " num  # Prompt user for a number and store in 'num'

if [ -z "$num" ]; then  # Check if 'num' is empty (user did not input anything)
    echo "No input provided. Please enter a valid number."  # If true, print a warning
elif ! [[ "$num" =~ ^[0-9]+$ ]]; then  # Check if the input is not a number using a regex pattern
    echo "Invalid input. Please enter a numeric value."  # If true, print an invalid input message
elif [ $num -ge 1 ] && [ $num -le 10 ]; then  # Check if the number is between 1 and 10 (inclusive)
    echo "You entered a valid number: $num"  # If true, print a success message
    if [ $num -lt 5 ]; then  # Additional check: if the number is less than 5
        echo "Your number is less than 5."  # If true, print this message
    else
        echo "Your number is 5 or greater."  # If false, print this message
    fi
else
    echo "Number out of range. Please enter a number between 1 and 10."  # If the number is out of range, print this
fi  # End of the if-elif-else structure
