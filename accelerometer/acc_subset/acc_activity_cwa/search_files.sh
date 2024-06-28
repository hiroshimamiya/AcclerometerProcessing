#!/bin/bash

# Define the location of the ID file
id_file="/home/kapmcgil/projects/def-hiroshi/kapmcgil/eids.txt"
cd /lustre03/project/6008063/neurohub/UKB/Bulk/90001

# Read IDs and build a search pattern
pattern=$(awk '{print $1}' $id_file | paste -sd '|')

# Loop through each directory and search for files matching the IDs
for dir in */ ; do
    if [[ -d "$dir" && "$dir" =~ ^[0-9]+ ]]; then  # Only search in numeric directories
        echo "Searching in directory $dir"
        find "$dir" -type f -regextype posix-extended -regex ".*($pattern).*" -print
    fi
done
