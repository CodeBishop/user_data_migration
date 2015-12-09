#creating user and changing its password
user_file="output.txt"
pass_file="pass.txt"

createUser(){
$(newusers -r "$user_file")
chpasswd -e < $2
}
checkingFileExitance(){
	if [ ! -f $user_file ]
	then
		echo "User File not found!"
		exit
	fi
	if [ ! -f $pass_file ]
	then
		echo "Password File not found!"
		exit
	fi
}


deleteFile(){
	rm "$user_file"
	rm "$pass_file"
}

if [ -z "$user_file" ] 
                   # Is file exist
then
	echo "please enter a user file"
	exit
else
	if [ -z "$pass_file" ]			# Have you input a file?
	then
		echo "please enter a user file"
		exit
	else
		checkingFileExitance		
		createUser $user_file $pass_file
		deleteFile $user_file $pass_file
	fi
fi
