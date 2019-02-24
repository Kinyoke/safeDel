#!/usr/bin/env bash
#Author: Faisal Burhan
#Cpyright (c) Neutron.net
#This is a monitor script, that start a new process from the safeDel.
#The script's purpose is to monitor the use of the trashCan directory every 15s

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

function main(){
	
	cd ~/.trashCan

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

	#calculate file md5 digest checksum
	
	for filename in $prevFiles;
	do
		if [[ ( -f $filename || -d $filename ) ]]; then
			
			md5=$( md5sum $filename | awk '{ print $1 }' )
			
			o_f_Digest[$filename]=$md5

		fi

	done

	init_monitor

	while :
	do
		tracker
		sleep 15
	done

}



function tracker(){

	currentFileCount=$(ls -1q | wc -l)
	hashChanged=0

	for filename in $currentFiles;
	do
		if [[ ( -f $filename || -d $filename ) ]]; then
			
			md5=$( md5sum $filename | awk '{ print $1 }')
			
			n_f_Digest[$filename]=$md5
		
		fi

	done
	
	c_index=0

	for key in "${!n_f_Digest[@]}";
	do
		if [[ (${o_f_Digest[$key]} != ${n_f_Digest[$key]} && ${o_f_Digest[$key]} != "") ]]; then
			
			hashChanged=$((1))
			let c_index++
			changedFiles[$c_index]=$key
			#o_f_Digest[$key]=${n_f_Digest[$key]}
			ChangedFileCount=$(($c_index))
	
		fi

		o_f_Digest[$key]=${n_f_Digest[$key]}
	done

	
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

	for filename in $currentFiles;
	do
		let n_f_pointer++
		newFiles[$n_f_pointer]=$filename
	done	

	for filename in $prevFiles;
	do
		let o_f_pointer++
		oldFiles[$o_f_pointer]=$filename

	done
	

	if [[ $o_f_pointer -gt $n_f_pointer ]]; then
		
		#check for deleted files
		index=0
		let index++
		for((i=1;i<=$o_f_pointer;i++))
		do
			for((j=1;j<=$n_f_pointer;j++))
			do
				#echo "$i , $j >> ${newFiles[$j]}: :${oldFiles[$i]}"
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
				#echo "$i, $j >> '${newFiles[$i]}': :'${oldFiles[$j]}'"
				if [[ ${newFiles[$i]} = ${oldFiles[$j]} ]]; then
					newFiles[$i]=""
				fi
			done
			tmpFiles[$i]=${newFiles[$i]}
		done

	fi


	if [[ $n_f_pointer != $o_f_pointer ]];then
		prevFiles=$currentFiles
	fi


	printf "\n%-13s %-s\n" "" "+--------------------------------+----------------+"

	printf "%-14s|%-32s|%-16s|\n" "" "FILE COUNT" "$currentFileCount"

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
	
	CreatedFileCount=$(( 0 ))
	DeletedFileCount=$(( 0 ))
	ChangedFileCount=$(( 0 ))
}


#run main function.
main

