

# Rough draft
#If argc != 3 or --help given then output the usage method.
#If pre-authorized ssh access is unavailable at the source and/or destination then prompt for the password so it can be setup.
#Read the source passwd and shadow files into an internal array of user data.
#Iterate through the array executing useradd remotely at the destination.


#For each username in list_of_users:
#    $passwd_result = grep /etc/passwd
#    $shadow_result = grep /etc/shadow
#    if passwd_result and shadow_result are both not null:
#        split the passwd_result into its fields
#        split the shadow_result into its fields
#        use ssh to call useradd on remote machine with the extracted fields


#!/bin/bash
#while IFS='' read -r line || [[ -n "$line" ]]; do
while read user_name; do
    # Get user entries from /etc/passwd and /etc/shadow.
    passwd_result=$(grep "^$user_name:" /etc/passwd)
    shadow_result=$(grep "^$user_name:" /etc/shadow)

    # If user entries were found extract date from them.
    if [ ! -z "$passwd_result" ] && [ ! -z "$shadow_result" ]; then
        # /etc/passwd entries are of the form "username:password:userID:groupID:gecos:homeDir:shell"
        IFS=':' read -r -a passwd_fields <<< "$passwd_result"
        # /etc/
        IFS=':' read -r -a shadow_fields <<< "$shadow_result"
        echo ${shadow_fields[1]}
        # The following indices are based on the standard ordering used in /etc/passwd and /etc/shadow:
        #    username:password:userID:groupID:gecos:homeDir:shell
        #    username:password
#        useradd -u ${passwd_fields[2]} -g ${passwd_fields[3]} -c "${passwd_fields[4]}" -M -s /sbin/nologin ${passwd_fields[0]}
    fi
done <"$1"

exit 0

