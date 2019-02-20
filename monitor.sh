#!/usr/bin/env bash
#Author: Faisal Burhan
#Cpyright (c) Neutron.net
#This is a monitor script, that start a new process from the safeDel.
#The script's purpose is to monitor the use of the trashCan directory every 15s

NAME="Faisal Burhan Abdu"
STUDENT_ID="S1719016"
PROMPT="[MONITOR-INFO]:"


function main(){


	COLUMNS=$(tput cols)
	WELCOME_MSG_OP="============== WELCOME =============="
	STID_N="STUDENT_NAME: $NAME"
	STID_ID="STUDENT_ID: $STUDENT_ID"
	WELCOME_MSG_CL="====================================="	
	
	printf "\n\n\n"
	printf "%*s\n" $(((${#WELCOME_MSG_OP}+$COLUMNS)/2)) "$WELCOME_MSG_OP"
	printf "%*s\n" $(((${#STID_N}+$COLUMNS)/2)) "$STID_N"
	printf "%*s\n" $(((${#STID_ID}+$COLUMNS)/2)) "$STID_ID"
	printf "%*s\n\n" $(((${#WELCOME_MSG_CL}+$COLUMNS)/2)) "$WELCOME_MSG_CL"
	printf "\n\n"

	while :
	do
		init_monitor
		sleep 15
	done

}

function init_monitor(){

	echo -e "$PROMPT monitor is running press [CTRL + C] to stop"

}

#run main function.
main

