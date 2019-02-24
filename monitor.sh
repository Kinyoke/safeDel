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
	
	currentFileCount=$(( $PreviousFileCount ))

	#initialize files available in the trashCan directory

	prevFiles=$(ls)

	init_monitor

	while :
	do
		tracker
		sleep 15
	done

}


function tracker(){

	currentFileCount=$(ls -1q | wc -l)

	if [[ $currentFileCount != $PreviousFileCount ]];then

		init_monitor
	fi

}

function init_monitor(){

	printf "\n%-13s %-s\n" "" "+--------------------------------+----------------+"

	printf "%-14s|%-32s|%-16s|\n" "" "FILE COUNT" "$currentFileCount"

	if [[ $currentFileCount -gt $PreviousFileCount ]];then
		
		CreatedFileCount=`expr $currentFileCount - $PreviousFileCount`
		printf "%-14s|%-32s|%-16s|\n" "" "CREATED FILES" "$CreatedFileCount"
		printf "\n%-14s %-8s  %-8s" "" "NO" "FILE"
		ls -l | awk '{printf("%-14s %-9s %-9s %-9s\n","", $4, $8, $9)}'
		echo -e "\n"
		PreviousFileCount=$(( $currentFileCount ))
	else
		printf "%-14s|%-32s|%-16s|\n" "" "CREATED FILES" "$CreatedFileCount"
	
	fi

	if [[ $currentFileCount -lt $PreviousFileCount ]];then
		DeletedFileCount=`expr $PreviousFileCount - $currentFileCount`
		printf "%-14s|%-32s|%-16s|\n" "" "DELETED FILES" "$DeletedFileCount"
		printf "\n%-14s %-8s  %-8s" "" "NO" "FILE"
		ls -l | awk '{printf("%-14s %-9s %-9s %-9s\n","", $4, $8, $9)}'
		echo -e "\n"
		PreviousFileCount=$(( $currentFileCount ))
	else
		printf "%-14s|%-32s|%-16s|\n" "" "DELETED FILES" "$DeletedFileCount"
	fi

 
	printf "%-14s|%-32s|%-16s|\n" " " "CHANGED FILES" "$ChangedFileCount"

	printf "%-13s %-s\n" "" "+--------------------------------+----------------+"
	
	#initialize current available files in trashCan dir
	
	currentFiles=$(ls )
	n_f_pointer=0
	o_f_pointer=0

	declare -a newFiles
	declare -a oldFiles

	for filename in $currentFiles;
	do
		let n_f_pointer++
		newFiles[$n_f_pointer]=$filename
	done	


	echo -e "\nCURRENT FILES\n${newFiles[@]}\n"


	for filename in $prevFiles;
	do
		let o_f_pointer++
		oldFiles[$o_f_pointer]=$filename

	done

	echo -e "\nOLD FILES\n${oldFiles[@]}\n"

	#check for deleted files

	for((i=1;i<=$n_f_pointer;i++))
	do
		#echo "$i: ${newFiles[$i]}"

		for((j=1;j<=$o_f_pointer;j++))
		do
			echo "$i , $j >> ${newFiles[$i]}: :${oldFiles[$j]}"

			#fdfdfff
		done
	done

	if [[ $n_f_pointer != $o_f_pointer ]];then
		prevFiles=$currentFiles
	fi

}


#for fgbg in 38 48 ; do # Foreground / Background
#    for color in {0..255} ; do # Colors
        # Display the color
#        printf "\e[${fgbg};5;%sm  %3s  \e[0m" $color $color
        # Display 6 colors per lines
#        if [ $((($color + 1) % 6)) == 4 ] ; then
#           echo # New line
#        fi
#    done
#    echo # New line
#done

#run main function.
main

