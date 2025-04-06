#Simple Example (Check if a number is positive, negative, or zero)
#!/bin/bash

# Simple example: Check if a number is positive, negative, or zero

num=5  # Assign a value to the variable 'num'

if [ $num -gt 0 ]; then  # Check if 'num' is greater than 0 (positive)
    echo "$num is positive"  # If true, print that the number is positive
elif [ $num -lt 0 ]; then  # Check if 'num' is less than 0 (negative)
    echo "$num is negative"  # If true, print that the number is negative
else
    echo "$num is zero"  # If neither condition is true, print that the number is zero
fi  # End of the if-elif-else structure