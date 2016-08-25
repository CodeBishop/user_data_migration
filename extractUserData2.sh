#!/bin/bash

# A pipeable version of extractUserData.sh

# Indices of data members in an /etc/passwd entry.
index_user=0
index_password=1
index_uid=2
index_gid=3
index_gecos=4
index_dir=5
index_shell=6

case "$1" in
    "--help")
        echo "A pipeable script for extracting user entries from /etc/passwd."
        echo "Usage: $0 [OPTIONS]"
        echo
        echo "Options:"
        echo "  --help   display this message"
        echo "  -r       report missing users to stderr"
        exit 0
    ;;
    "-r")
        reportMissingUsers="true"
    ;;
esac

# Read usernames to convert to /etc/passwd entries.
while read user_name; do
    # Search for username in /etc/passwd
    user_result=$(grep "^$user_name:" /etc/passwd) # Entry line must start with username followed by a colon in order to match.
    
    # If a match was found then process it.
    if [ ! -z $user_result ]; then
        # Split the user's entry by colons into an array.
        IFS=':' read -r -a array_of_field_data <<< "$user_result"

        # Convert the array to a set of fields.
        field_user=${array_of_field_data[index_user]}
        field_password=${array_of_field_data[index_password]}
        field_uid=${array_of_field_data[index_uid]}
        field_gid=${array_of_field_data[index_gid]}
        field_gecos=${array_of_field_data[index_gecos]}
        field_dir=${array_of_field_data[index_dir]}
        field_shell="nologin"  # Disable shell access.

        # Output reconstructed user entry.
        user_entry="$field_user:$field_password:$field_uid:$field_gid:$field_gecos:$field_dir:$field_shell"
        echo $user_entry
    else
        if [ "$reportMissingUsers" == true ]; then
            # Report missing users to file descriptor #2 (stderr).
            >&2 echo "  No record was found for user: $user_name"
        fi
    fi
done
