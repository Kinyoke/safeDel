#!/usr/bin/env bash
#Author: Faisal Burhan
#Cpyright (c) Neutron.net
#This is a monitor script, that start a new process from the safeDel.
#The script's purpose is to monitor the use of the trashCan directory every 15s

#Global variable declaration below.

NAME="Faisal Burhan Abdu"

STUDENT_ID="S1719016"

PROMPT="[INFO]:"

PreviousFileCount=0

currentFileCount=0

PrevFiles=""

currentFiles=""

CreatedFileCount=0

DeletedFileCount=0

ChangedFileCount=0

declare -A o_f_Digest

declare -A n_f_Digest

declare -a changedFiles


# implements a main function

function main(){
	
	#change from current working directory to trashCan directory.

	cd ~/.trashCan
	
	# set monitor header format

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
	
	#initialize file count available in the trashCan directory
	
	PreviousFileCount=$(ls -1q | wc -l)

	#initialize files available in the trashCan directory

	prevFiles=$(ls)

	#initialize current files count once

	currentFileCount=$(($PreviousFileCount))

	#calculate previous file md5 digest checksum
	
	for filename in $prevFiles;
	do
		if [[ ( -f $filename || -d $filename ) ]]; then
			
			md5=$( md5sum $filename | awk '{ print $1 }' )
			
			o_f_Digest[$filename]=$md5

		fi

	done

	# intialize monitor values by calling function below

	init_monitor

	# enter main loop

	while :
	do
		# call tracker to track changes in the trashCan file system

		tracker
		
		# sleep for 15 seconds then repeat

		sleep 15
	done

}

# the tracker function below checks for any changes happened in the trash can dir
# and invokes the init_monitor function to handle the displaying of the content 
# in a formatted and organized way.

function tracker(){

	#checks for current file counts in a trashCan directory

	currentFileCount=$(ls -1q | wc -l)

	#declare and initalize hasChanged flag below
	
	hashChanged=0

	#iterate through each file in the trashCan directory and calculate their hash

	for filename in $currentFiles;
	do
		if [[ ( -f $filename || -d $filename ) ]]; then
			
			md5=$( md5sum $filename | awk '{ print $1 }')
			
			n_f_Digest[$filename]=$md5
		
		fi

	done
	
	c_index=0

	#compare if the file's md5 checksum is the same as it was 15 seconds ago

	for key in "${!n_f_Digest[@]}";
	do
	
		if [[ (${o_f_Digest[$key]} != ${n_f_Digest[$key]} && ${o_f_Digest[$key]} != "") ]]; then
			
			hashChanged=$((1))
	
			let c_index++

			changedFiles[$c_index]=$key

			ChangedFileCount=$(($c_index))
	
		fi

		o_f_Digest[$key]=${n_f_Digest[$key]}

	done
	
	# call init_monitor to display the output to the user if there any created/delete or edit changes
	# found in the trashCan directory
	
	if [[ ( $currentFileCount != $PreviousFileCount || $hashChanged -gt 0)  ]];then

		init_monitor

		hashChanged=$((0))

	fi


}

function init_monitor(){
	

	#initialize current available files in trashCan dir

	currentFiles=$(ls)

	n_f_pointer=0

	o_f_pointer=0

	counter=0

	declare -a newFiles

	declare -a oldFiles

	declare -a tmpFiles

	# set all new available file file's name from the trashCan dir

	for filename in $currentFiles;
	do

		let n_f_pointer++

		newFiles[$n_f_pointer]=$filename

	done	

	# set all old file file's name 

	for filename in $prevFiles;
	do

		let o_f_pointer++

		oldFiles[$o_f_pointer]=$filename

	done
	
	# check for any pointer difference that indicates file counts changes within 15
	# seconds in the trashCan directory

	if [[ $o_f_pointer -gt $n_f_pointer ]]; then
		
		#check for deleted files

		index=0

		let index++

		for((i=1;i<=$o_f_pointer;i++))
		do

			for((j=1;j<=$n_f_pointer;j++))
			do

				if [[ ${newFiles[$j]} = ${oldFiles[$i]} ]]; then

					oldFiles[$i]=""

				fi

			done

			tmpFiles[$i]=${oldFiles[$i]}

		done
	fi

	if [[ $n_f_pointer -gt $o_f_pointer ]]; then
		
		#check for added files

		index=0

		let index++

		for((i=1;i<=$n_f_pointer;i++))
		do	
			for((j=1;j<=$o_f_pointer;j++))
			do

				if [[ ${newFiles[$i]} = ${oldFiles[$j]} ]]; then

					newFiles[$i]=""

				fi

			done

			tmpFiles[$i]=${newFiles[$i]}

		done

	fi
	
	# swap current file names to be the previous name if there any file cahnges difference

	if [[ $n_f_pointer != $o_f_pointer ]];then

		prevFiles=$currentFiles

	fi


	printf "\n%-13s %-s\n" "" "+--------------------------------+----------------+"

	printf "%-14s|%-32s|%-16s|\n" "" "FILE COUNT" "$currentFileCount"

	# check for any newly created file in the trashCan directory and display it to the user

	if [[ $currentFileCount -gt $PreviousFileCount ]];then
		
		CreatedFileCount=`expr $currentFileCount - $PreviousFileCount`

		printf "%-14s|%-32s|%-16s|\n" "" "CREATED FILES" "$CreatedFileCount"

		printf "\n%-14s %-8s  %-8s\n" "" "NO" "FILE"
		
		for((i=1;i<=$n_f_pointer;i++))
		do

			if [[ ${tmpFiles[$i]} != "" ]]; then

				let counter++

				printf "%-14s %-9s \e[34m%-9s\e[0m\n" "" $counter ${tmpFiles[$i]}

			fi
		done

		echo -e "\n"

		PreviousFileCount=$(( $currentFileCount ))

	else

		printf "%-14s|%-32s|%-16s|\n" "" "CREATED FILES" "$CreatedFileCount"
	
	fi

	# check for any file deletion and display to the user

	if [[ $currentFileCount -lt $PreviousFileCount ]];then

		DeletedFileCount=`expr $PreviousFileCount - $currentFileCount`

		printf "%-14s|%-32s|%-16s|\n" "" "DELETED FILES" "$DeletedFileCount"

		printf "\n%-14s %-8s  %-8s\n" "" "NO" "FILE"

		for((i=1;i<=$o_f_pointer;i++))
		do

			if [[ ${tmpFiles[$i]} != "" ]]; then

				let counter++

				printf "%-14s %-9s \e[91m%-9s\e[0m\n" "" $counter ${tmpFiles[$i]}

			fi

		done

		echo -e "\n"

		PreviousFileCount=$(( $currentFileCount ))

	else

		printf "%-14s|%-32s|%-16s|\n" "" "DELETED FILES" "$DeletedFileCount"

	fi


	# check for any available changes and display to the user


	if [[ $ChangedFileCount -gt 0 ]]; then
		
		printf "%-14s|%-32s|%-16s|\n" " " "CHANGED FILES" "$ChangedFileCount"
		
		printf "\n%-14s %-8s  %-8s\n" "" "NO" "FILE"
		
		for((i=1;i<=$ChangedFileCount;i++))
		do

			if [[ ${changedFiles[$i]} != "" ]]; then
				
				printf "%-14s %-9s \e[93m%-9s\e[0m\n" "" $i ${changedFiles[$i]}

				changedFiles[$i]=""

			fi

		done
		

		echo -e "\n"

	else

		printf "%-14s|%-32s|%-16s|\n" " " "CHANGED FILES" "$ChangedFileCount"

	fi

	printf "%-13s %-s\n" "" "+--------------------------------+----------------+"


	# reset values back to zero
	
	CreatedFileCount=$(( 0 ))

	DeletedFileCount=$(( 0 ))

	ChangedFileCount=$(( 0 ))
}


# call main function below for execution.

main

