#!/usr/bin/env bash
#Author: Faisal Burhan
#Cpyright (c) Neutron.net
#This script is for testing purpose only.

NAME="Faisal Burhan Abdu"

STUDENT_ID="S1719016"

TRASH_CAN_DIR=~/.trashCan

trap ctrl_c SIGINT

trap exit_script EXIT

function main(){	#______________ BEGIN OF MAIN _____________________________

	echo "STUDENT_NAME: $NAME"
	echo "STUDENT_ID: $STUDENT_ID"

	#create a trashCan directory if not exist

	init_trashCan
	
	#check the number of user argument(s) counts to determine if there any inline argument(s) available.

	if [[ $# == 0 ]];then

		#go interactiive mode.

		init_interactive_mode
		
	else
		if [[ ($1 != -l  && $1 != -r && $1 != -w && $1 != -k && $1 != -d && $1 != -t && $1 != "--help") ]];then

			delete_file $@
		
		else
			
			#do the command line argument thing ehh.

			init_inlinecmd_mode $@
		
		fi

	fi
	
	#______________________ END OF MAIN ______________________	

	
}


#handle user parameters provided as inline argument to the safeDel


function init_inlinecmd_mode(){

	#do something...
	
	case $1 in

		-l)
			if [[ $# -gt 1 ]]; then
				display_help_menu
			else			
				#List all files from the trashCan directory"
				list_files
			fi
		;;
			
		-r) 
			if [[ $# -gt 1 ]];then		
				#recover files back to current directory"
				recover_files $@
			else
				display_help_menu
			fi
		;;

		-d) 
			#delete content interactively
			delete_file_intmode
		;;
		
		-t) 
			if [[ $# -gt 1 ]];then
				display_help_menu
			else	#display total trashCan usage in bytes
				display_tc_usage
			fi
		;;
		
		-w) 
			if [[ $# -gt 1 ]];then
				display_help_menu
			else	
				#start a monitor script on a new window
				init_monitor_sh
			fi	
		;;
		
		-k) 
			if [[ $# -gt 1 ]];then
				display_help_menu
			else
				#kill current user's monitor script process	
				kill_monitor_process
			fi
		;;
		
		--help | /?) 
			display_help_menu
		;;
		
		esac


}


#handle interactive mode below


function init_interactive_mode(){
	
	USAGE="usage: $0 <fill in correct usage>"

	#prepare the interactive menu list items

	((pos = OPTIND - 1))
	shift $pos

	PS3='option> '

	if (( $# == 0 ))
	then
		if (( $OPTIND == 1 )) 
		then
			select menu_list in list recover delete total watch kill exit
			do
				case $menu_list in
					"list") list_files;;
         				"recover") recover_files;;
         				"delete") delete_file_intmode;;
         				"total") display_tc_usage;;
         				"watch") init_monitor_sh;;
         				"kill") kill_monitor_process;;
         				"exit") exit 0;;
         				*) echo "unknown option";;
         			esac
      			done
 		fi
	else
		echo "extra args??: $@"
	fi



}


# create a trash can directory on safeDel call if it does not exist


function init_trashCan(){

	file=~/.trashCan

	if [[ ! -e $file ]]; then

		echo "creating .trashCan file"

		mkdir ~/.trashCan
	fi

}


# display help to the user of the safeDel utility on how to operate the tool.


function display_help_menu(){
	
	echo "usage: safeDel [DIRECTORY(S) | FILE(S)] [-l list files] [-w start monitor]"
	echo "               [-r file file ... recover files] [-d delete file permanently]"
	echo "               [-k kill monitor] [-t display usage]"

}

# delete files from the current working directory by moving the to the trashCan directory
#NOTE; specifically built to process inline arguments which represents a file name

function delete_file(){

	#set flag paramanter below

	flag=0
	zero=0
	msg=""

	for TOKEN in $@
	do
		#iterate through available arguments

		file=$TOKEN
		
		#validate if given argument or set of arguments resabmle either a regular file or directory signature

		if [[ -f $file ]];then
		
			msg="Moving file: $TOKEN to trash"
		
			flag=$(( $flag + 1 ))
		fi

		if [[ -d $file ]];then
		
			msg="Moving directory: $TOKEN to trash"
		
			flag=$(( $flag + 1 ))
		fi
		
		#check flag states and move the specified file(S) or folder(S) to the trashCan directory

		if [[ $flag -gt $zero ]];then

			echo $msg
			
			mv $TOKEN ~/.trashCan
			
			#reset flag back to zero
			
			flag=$(( 0 ))

		else
			echo "File or directory not found, operation cannot be completed!"

			#display_help_menu
		
		fi

	done

}


# list available files from the trashCan directory

function list_files(){

	# make sure the trashCan is not empty, then display its content to the user
	
	if [ -z "$(ls -A ~/.trashCan)" ]; then
   		echo "trashCan is empty!"

	else
		echo -e "Listing files from trashCan dir..."
		printf "%-20s  %-20s  %-20s\n" "FILE_NAME" "FILE_SIZE" "FILE_TYPE"
		#echo -e "FILE_NAME" "\tFILE_SIZE" "\tFILE_TYPE"
   		for f in ~/.trashCan/*; do
			printf "%-20s  %-20s %-20s\n" "$(basename $f) " "$(wc -c <"$f") " " $(file --mime-type -b "$f")"
		done
	fi
}

# recover files from the trashCand directory to back to the current working directory

function recover_files(){

	# set initial valiables for filename and file count existing in the trashCan directory

	FILES=$(ls $TRASH_CAN_DIR)
	fileCount=$(ls -1q $TRASH_CAN_DIR/ | wc -l)

	if [[ ($fileCount -gt 0 && $# -lt 1) ]]; then

		# prompt a user to choose an action to be performed

		read -p "Would you like all files from trashCan to be recovered (Y or n))? " option
		
		case $option in
			
			Y | y) 

				echo "recovering all trashCan content to current working directory..."
				
				for filename in $FILES;
				do

					if [[ -f $TRASH_CAN_DIR/$filename ]]; then
						
						mv $TRASH_CAN_DIR/$filename .
					
					fi

					if [[ -d $TRASH_CAN_DIR/$filename ]]; then

						mv  $TRASH_CAN_DIR/$filename .
					
					fi

				done

				echo "trashCan content moved successfully to current working directory..."

			;;
		N | n) 

				i=0
				
				# show the user available file(s) to be recovered from the trashCan directory
				echo "List of available files..."
				
				for filename in $FILES;
				do
					
					let i++
					echo $i": "$filename
				
				done
				
				read -p "Enter a file name or [file1 file2 file..] to recover:  " filename_i

				for filename in $filename_i;
				do
					if [[ -f $TRASH_CAN_DIR/$filename ]]; then

						echo "recovering $filename from trashCan to current working directory..."

						mv $TRASH_CAN_DIR/$filename .

					elif [[ -d $TRASH_CAN_DIR/$filename ]]; then

						echo "recovering $filename folder from trashCan to current working directory..."

						mv $TRASH_CAN_DIR/$filename .

					else

						echo "File do not exist!"

					fi

				done

			;;
	
		esac

	elif [[ $# -gt 1 ]]; then

		shift 1

		for filename in $@;
		do
			if [[ -f $TRASH_CAN_DIR/$filename ]]; then
				
				echo "recovering $filename file from trashCan to current working directory..."
				
				mv $TRASH_CAN_DIR/$filename .

			elif [[ -d $TRASH_CAN_DIR/$filename ]]; then

				echo "recovering $filename folder from trashCan to current working directory..."

				mv $TRASH_CAN_DIR/$filename .

			else

				echo "File not found, please make sure you provide the right file name!"

			fi
		
		done
	
	else
		
		echo "trashCan is empty!"
					
	fi


}

# terminate the current running monitor process


function kill_monitor_process(){

	# locate the process's process id
		
	PID=$(ps -x | grep monitor.sh | grep "[0-9]*.Ss+" | awk '{print $1}')

	# verify that the id is not less 0

	if [[ $PID -gt 0 ]];then
		echo "Terminating monitor process..."
		kill $PID
		echo "monitor process terminated successfully..."
	else
		echo "no monitor process running!"
	fi

}

# handle file deletion for interactive mode options

function delete_file_intmode(){


	FILES=$(ls $TRASH_CAN_DIR)
	fileCount=$(ls -1q $TRASH_CAN_DIR/ | wc -l)

	if [[ $fileCount -gt 0 ]]; then

		read -p "Would you like to permanently delete all files (Y or n))? " option
		
		case $option in
			
			Y | y) 

				echo "permanently deleting all the trashCan content..."
				
				for filename in $FILES;
				do

					if [[ -f $TRASH_CAN_DIR/$filename ]]; then
						
						rm $TRASH_CAN_DIR/$filename
					
					fi

					if [[ -d $TRASH_CAN_DIR/$filename ]]; then

						rm -r $TRASH_CAN_DIR/$filename/*
					
					fi

				done

				echo "trashCan content deleted successfully..."

			;;
		N | n) 

				i=0
				
				echo "List of available files..."
				
				for filename in $FILES;
				do
					
					let i++
					echo $i": "$filename
				
				done
				
				read -p "Enter a file name or [file1 file2 file..] to delete:  " filename_i

				for filename in $filename_i;
				do
					if [[ -f $TRASH_CAN_DIR/$filename ]]; then

						echo "deleting $filename file from trashCan..."

						rm $TRASH_CAN_DIR/$filename

					elif [[ -d $TRASH_CAN_DIR/$filename ]]; then

						echo "deleting $filename folder from trashCan..."

						rm -r $TRASH_CAN_DIR/$filename

					else

						echo "File do not exist!"

					fi

				done

			;;
	
		esac
	
	else
		
		echo "trashCan is empty!"
					
	fi

}



# start a monitor process on a new separate window

function init_monitor_sh(){


	echo "Initiate monitor process..."
		
	# get the monitor process's pid...

	PID=$(ps -x | grep monitor.sh | grep "[0-9]*.Ss+" | awk '{print $1}')

	# check if the monitor process is not already running...

	if [[ $PID -gt 0 ]];then
		echo "monitor script is already running..."
	else
		echo "monitor process started..."

		# invoke a new window with the monitor process running...
	
		gnome-terminal --command './monitor.sh' --hide-menubar --title="MONITOR" > .termout
	fi

}


# display current size of the trashCan directory.


function display_tc_usage(){

	# confirm that the directory is not empty

	if [ -z "$(ls -A ~/.trashCan)" ]; then
   		echo "trashCan is empty!"

	else
	
	# iterate through file by their size and sum them up to determine the total usage in bytes

		local totalSize=0
   		for f in ~/.trashCan/*; do
			fileSize="$(wc -c <"$f")"
			let totalSize=$"(totalSize+fileSize)"
		done
		echo "Total trashCan dir usage : "$totalSize "bytes"

	fi

}


# handle [CTRL + C] interrupt command


ctrl_c(){

	fileCount=$(ls -1q | wc -l)	

	fileCount=`expr $fileCount - 1`
	
	echo "available number of files in the trashCan is:  "$fileCount;  
	
	total_size=0

	for file in $TRASH_CAN_DIR/*; do
		fileSize=$(wc -c $file | awk '{print $1}')
		total_size=`expr $total_size + $fileSize`
	done

	if [[ $total_size -gt 1024 ]]; then
		
		echo "The size of your trashCan is" $total_size " bytes" 
		
		printf "\e[91m%s\e[0m" "WARNING: trashCan size exceeds 1 Kilobyte."
	fi

    	exit 130
}


# safe exit the script

exit_script(){
	
	echo -e "\r\nGoodbye $USER!" 
}



#script start execution from main function call below. 

main $@




#____________________________  END OF safeDel.sh SCRIPT  _________________________________


