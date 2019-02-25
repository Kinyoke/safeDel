#!/usr/bin/env bash
#Author: Faisal Burhan
#Cpyright (c) Neutron.net
#This script is for testing purpose only.

NAME="Faisal Burhan Abdu"

STUDENT_ID="S1719016"

TRASH_CAN_DIR=~/.trashCan

trap ctrl_c SIGINT

trap exit_script EXIT

function main(){

	echo "STUDENT_NAME: $NAME"
	echo "STUDENT_ID: $STUDENT_ID"

	init_trashCan

	if [[ $# == 0 ]];then

		init_interactive_mode
		
	else
		if [[ ($1 != -l  && $1 != -r && $1 != -w && $1 != -k && $1 != -d && $1 != -t && $1 != "--help") ]];then

			delete_file $@
		
		else

			init_inlinecmd_mode $@
		
		fi

	fi
	
}



function init_inlinecmd_mode(){
	
	case $1 in

		-l)
			if [[ $# -gt 1 ]]; then
				display_help_menu
			else			
				list_files
			fi
		;;
			
		-r) 
			if [[ $# -gt 1 ]];then		

				recover_files $@
			else
				display_help_menu
			fi
		;;

		-d) 
			delete_file_intmode
		;;
		
		-t) 
			if [[ $# -gt 1 ]];then
				display_help_menu
			else
				display_tc_usage
			fi
		;;
		
		-w) 
			if [[ $# -gt 1 ]];then
				display_help_menu
			else	
				init_monitor_sh
			fi	
		;;
		
		-k) 
			if [[ $# -gt 1 ]];then
				display_help_menu
			else	
				kill_monitor_process
			fi
		;;
		
		--help | /?) 
			display_help_menu
		;;
		
		esac


}



function init_interactive_mode(){
	
	USAGE="usage: $0 <fill in correct usage>"

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


function init_trashCan(){

	file=~/.trashCan

	if [[ ! -e $file ]]; then

		echo "creating .trashCan file"

		mkdir ~/.trashCan
	fi

}



function display_help_menu(){
	
	echo "usage: safeDel [DIRECTORY(S) | FILE(S)] [-l list files] [-w start monitor]"
	echo "               [-r file file ... recover files] [-d delete file permanently]"
	echo "               [-k kill monitor] [-t display usage]"

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
			
			flag=$(( 0 ))

		else
			echo "File or directory not found, operation cannot be completed!"

		
		fi

	done

}



function list_files(){

	if [ -z "$(ls -A ~/.trashCan)" ]; then
   		echo "trashCan is empty!"

	else
		echo -e "Listing files from trashCan dir..."
		printf "%-20s  %-20s  %-20s\n" "FILE_NAME" "FILE_SIZE" "FILE_TYPE"
   		for f in ~/.trashCan/*; do
			printf "%-20s  %-20s %-20s\n" "$(basename $f) " "$(wc -c <"$f") " " $(file --mime-type -b "$f")"
		done
	fi
}

function recover_files(){

	FILES=$(ls $TRASH_CAN_DIR)
	fileCount=$(ls -1q $TRASH_CAN_DIR/ | wc -l)

	if [[ ($fileCount -gt 0 && $# -lt 1) ]]; then

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


function kill_monitor_process(){

	PID=$(ps -x | grep monitor.sh | grep "[0-9]*.Ss+" | awk '{print $1}')

	if [[ $PID -gt 0 ]];then
		echo "Terminating monitor process..."
		kill $PID
		echo "monitor process terminated successfully..."
	else
		echo "no monitor process running!"
	fi

}


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


function init_monitor_sh(){


	echo "Initiate monitor process..."

	PID=$(ps -x | grep monitor.sh | grep "[0-9]*.Ss+" | awk '{print $1}')

	if [[ $PID -gt 0 ]];then
		echo "monitor script is already running..."
	else
		echo "monitor process started..."
	
		gnome-terminal --command './monitor.sh' --hide-menubar --title="MONITOR" > .termout
	fi

}


function display_tc_usage(){

	if [ -z "$(ls -A ~/.trashCan)" ]; then
   		echo "trashCan is empty!"

	else
	
		local totalSize=0
   		for f in ~/.trashCan/*; do
			fileSize="$(wc -c <"$f")"
			let totalSize=$"(totalSize+fileSize)"
		done
		echo "Total trashCan dir usage : "$totalSize "bytes"

	fi

}



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

exit_script(){
	
	echo -e "\r\nGoodbye $USER!" 
}


main $@


