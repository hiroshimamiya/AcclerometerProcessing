#!/bin/bash

# Define the source file list and destination directory
file_list="/home/kapmcgil/projects/def-hiroshi/kapmcgil/file_paths.txt"
destination="/home/kapmcgil/projects/def-hiroshi/kapmcgil/acc_activity"  # Change this to your actual destination path
cd /lustre03/project/6008063/neurohub/UKB/Bulk/90001

# Check if the destination directory exists, if not, create it
if [ ! -d "$destination" ]; then
    mkdir -p "$destination"
fi

# Read each file path from the file list and copy it to the destination
while IFS= read -r file_path; do
    if [ -f "$file_path" ]; then  # Check if the file exists
        echo "Copying $file_path to $destination"
        cp "$file_path" "$destination"
    else
        echo "File not found: $file_path"
    fi
done < "$file_list"

echo "All files have been copied."
