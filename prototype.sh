#!/usr/bin/env bash
#Author: Faisal Burhan
#Cpyright (c) Neutron.net
#This script is for testing purpose only.

echo "=== THIS IS JUST A TESTING ENVIRONMENT ==="

#TEST="Unix Programming"

#echo $PWD

#echo $DISPLAY

#echo $RANDOM

#echo $TEST

#read PERSON

#echo "Hello $PERSON welcome to system programming"


function main(){

	#create a trashCan directory if not exist

	init_trashCan
	
	#check the number of user argument(s) counts to determine if there any inline argument(s) available.

	if [[ $# == 0 ]];then

		#Display a menu to the user

		display_help_menu
	fi


	delete_file $@
}

function init_trashCan(){

	file=~/.trashCan

	if [[ ! -e $file ]]; then

		echo "creating .trashCan file"

		mkdir ~/.trashCan
	fi

}

function read_file(){

	while read line; do
		echo $line
	done < $1

}

function display_help_menu(){
	
	echo "usage: safeDel [OPTION]... [DIRECTORY(S) | FILE(S)]"

}

function delete_file(){

	flag=0
	zero=0
	msg=""

	for TOKEN in $@
	do
		file=$TOKEN

		if [[ -f $file ]];then
		
			msg="Moving file: $TOKEN to trash"
		
			flag=$(( $flag + 1 ))
		fi

		if [[ -d $file ]];then
		
			msg="Moving directory: $TOKEN to trash"
		
			flag=$(( $flag + 1 ))
		fi
		
		if [[ $flag -gt $zero ]];then

			echo $msg
			
			mv $TOKEN ~/.trashCan
			
			#reset flag back to zero
			
			flag=$(( 0 ))
		
		fi

	done

}




#script start execution from main function call below. 

main $@


#END OF safeDel.sh
