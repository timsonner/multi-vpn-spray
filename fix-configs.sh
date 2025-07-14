#!/bin/bash

# Script to fix all OpenVPN configuration files
# 1. Remove the keysize 256 line (incompatible with newer OpenVPN)
# 2. Update auth-user-pass to use auth.txt file

echo "Fixing OpenVPN configuration files..."

# Process all .ovpn files in the current directory
for file in *.ovpn; do
    if [ -f "$file" ]; then
        echo "Processing: $file"
        
        # Create a temporary file
        temp_file=$(mktemp)
        
        # Process the file line by line
        while IFS= read -r line; do
            # Skip the keysize line entirely
            if [[ "$line" == "keysize 256" ]]; then
                continue
            # Replace auth-user-pass lines
            elif [[ "$line" == "auth-user-pass" ]]; then
                echo "auth-user-pass auth.txt" >> "$temp_file"
            # Keep all other lines as-is
            else
                echo "$line" >> "$temp_file"
            fi
        done < "$file"
        
        # Preserve original file permissions
        chmod --reference="$file" "$temp_file"
        
        # Replace the original file with the fixed version
        mv "$temp_file" "$file"
        
        echo "Fixed: $file"
    fi
done

echo "All configuration files have been updated!"
echo ""
echo "Changes made:"
echo "1. Removed 'keysize 256' lines (incompatible with OpenVPN 2.6+)"
echo "2. Updated 'auth-user-pass' to 'auth-user-pass auth.txt'"
echo ""
echo "Make sure your auth.txt file contains:"
echo "your_username"
echo "your_password"
