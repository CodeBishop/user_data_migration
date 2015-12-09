#!/bin/bash
#don't change these
array_user=0
array_password=1
array_uid=2
array_gid=3
array_gecos=4
array_dir=5
array_shell=6

#These are changeable, can be empty string
user_replacement="$1" #will be whatever you replace user as. Default value is paramater one
password_replacement=""
uid_replacement=""
gid_replacement=""
gecos_replacement=""
dir_replacement=""
shell_replacement=""
#changeable but must exist
file="output.txt"
passwd_file="pass.txt"
remoteHost="ryancua@192.168.20.130"
des_directory="/home/ryancua"

#Extracting details and save it into a output file
extractDetails ()
{
	user_result=$(grep "^$1:" /etc/passwd)
	IFS=':' read -r -a array <<< "$user_result"
	new_user=$(checkingThings $user_replacement "${array[array_user]}")  # If custom input exist (ie user_replacement), it will return that. Else return default one
	new_password=$(checkingThings $password_replacement "${array[array_password]}")
	new_uid=$(checkingThings $uid_replacement "${array[array_uid]}")
	new_gid=$(checkingThings $gid_replacement "${array[array_gid]}")
	new_gecos=$(checkingThings $gecos_replacement "${array[array_gecos]}")
	new_dir=$(checkingThings $dir_replacement "${array[array_dir]}")
	new_shell=$(checkingThings $shell_replacement "${array[array_shell]}")
	temp="$new_user:$new_password:$new_uid:$new_gid:$new_gecos:$new_dir:$new_shell"
	echo $temp>> "$file"
}
#extract encrypted password
extractPassword(){
	IFS=':' read -r -a array <<< "$2"
	pass="${array[array_password]}"
	echo "$1:$pass" >> "$passwd_file"	
}
copyToRemote(){
rsync -zvh "$file" "$remoteHost":"$des_directory"
rsync -zvh "$passwd_file" "$remoteHost":"$des_directory"
rsync -zvh "createUser.sh" "$remoteHost":"$des_directory"
}

#comparing if one of them is empty. If parameter one is empty then it will return parameter 2 else otherway around.
#This assumes at least one is not empty
# Parameter one is always the replacement string
checkingThings(){
	if [ -z "$1" ]                          
	then	
		echo $2
	else
		echo $1
	fi
}

checkMissingRequirements(){
	if [ -z "$file" ]
	then
		echo 'output file ($file) is empty. Exiting program'
		exit
	fi
	if [ -z "$passwd_file" ]
	then
		echo 'output password file ($passwd_file) is empty. Exiting program'
		exit
	fi
	if [ -z "$remoteHost" ]
	then
		echo '$remoteHost is empty. Exiting program'
		exit
	fi
	if [ -z "$des_directory" ]
	then
		echo '$des_directory is empty. Exiting program'
		exit
	fi

}


#removeUser for testing
removeUser(){
	sudo deluser --remove-home "$1"
}



isUserExist(){
	if [ -z "$1" ]          # if user does not exist
	then
		return 1
	else	
				
		return 0
	fi
}


if [ -z "$1" ]                 #is password parameter empty?
then
	echo 'no user input exiting program'
	exit
	
else	
	checkMissingRequirements
	user_password_result=$(sudo grep "^$1:" /etc/shadow)
	if isUserExist "$user_password_result" 
	then 
		extractPassword "$1" "$user_password_result"
		extractDetails "$1"
		copyToRemote
	else
		echo "user does not exist"
		exit
	fi
fi


