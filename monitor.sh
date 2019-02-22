#!/usr/bin/env bash
#Author: Faisal Burhan
#Cpyright (c) Neutron.net
#This is a monitor script, that start a new process from the safeDel.
#The script's purpose is to monitor the use of the trashCan directory every 15s

NAME="Faisal Burhan Abdu"
STUDENT_ID="S1719016"
PROMPT="[INFO]:"


function main(){


	COLUMNS=$(tput cols)
	WELCOME_MSG_OP="============== WELCOME =============="
	STID_N="STUDENT_NAME: $NAME"
	STID_ID="STUDENT_ID: $STUDENT_ID"
	WELCOME_MSG_CL="====================================="
	CLOSE_WINDOW="$PROMPT monitor is running press [CTRL + C] to stop"	
	
	printf "\n\n\n"
	printf "%*s\n" $(((${#WELCOME_MSG_OP}+$COLUMNS)/2)) "$WELCOME_MSG_OP"
	printf "%*s\n" $(((${#STID_N}+$COLUMNS)/2)) "$STID_N"
	printf "%*s\n" $(((${#STID_ID}+$COLUMNS)/2)) "$STID_ID"
	printf "%*s\n\n" $(((${#WELCOME_MSG_CL}+$COLUMNS)/2)) "$WELCOME_MSG_CL"

	printf "%*s\n\n" $(((${#CLOSE_WINDOW}+$COLUMNS)/2)) "$CLOSE_WINDOW" 

	while :
	do
		init_monitor
		sleep 15
	done

}

function init_monitor(){

	#ls -al  ~/.trashCan
	fileCount=$(ls -1q ~/.trashCan/ | wc -l)
	echo -e "\n\n"
	echo -e "+----------------------------------------+-------------------------------------+"
	echo -e "|  FILE COUNT		                 |		$fileCount                      |" 
	echo -e "+----------------------------------------+-------------------------------------+"
	echo -e "|  CREATED FILES                        |                                              |"
	echo -e "+----------------------------------------+--------------------------------------+"
	for filename in ~/.trashCan;
	do
		for ((i=0; i<=$fileCount-1; i++)); 
		do
			echo "$filename"
    		done
	done

}

#run main function.
main

