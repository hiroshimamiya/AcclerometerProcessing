#!/bin/bash

directory="/home/aayush/accelerometer/acc_subset/acc_activity_accProcessed"

output_file="line_counts.txt"

# Clear the output file if it exists
> $output_file

# List files in the directory and process each one
for file in "$directory"/*; do
  if [ -f "$file" ]; then
    # Get the number of lines in the file
    line_count=$(cat "$file" | wc -l)
    # Save the count with the file name
    echo "$(basename "$file"): $line_count" >> $output_file
  fi
done

# Display the final output
cat $output_file
