#!/usr/bin/env bash
#Author: Faisal Burhan
#Cpyright (c) Neutron.net
#This script is for testing purpose only.

NAME="Faisal Burhan Abdu"
STUDENT_ID="S1719016"




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
				echo "recover files back to current directory"
				recover_files $@
			else
				display_help_menu
			fi
		;;

		-d) 
			echo "delete content interactively"
		;;
		
		-t) 
			if [[ $# -gt 1 ]];then
				display_help_menu
			else	
				echo "display total usage in byte of the trashCan directory"	
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
					"list") echo "l";;
         				"recover") echo "r";;
         				"delete") echo "d";;
         				"total") echo "t";;
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

		else
			echo "File or directory not found, operation cannot be completed!"

			#display_help_menu
		
		fi

	done

}



function list_files(){

	echo "Listing files from trashCan directory..."
	
	ls -al ~/.trashCan


}


function recover_files(){
	
	shift 1

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
			
			mv ~/.trashCan/$@ .
			
			#reset flag back to zero
			
			flag=$(( 0 ))

		else
			echo "File or directory not found, operation cannot be completed!"

			#display_help_menu
		
		fi

	done

}


function kill_monitor_process(){

	#Terminating currect running monitor process
		
	PID=$(ps -x | grep monitor.sh | grep "[0-9]*.Ss+" | awk '{print $1}')

	if [[ $PID -gt 0 ]];then
		kill $PID
	fi

}

function delete_file_intmode(){

	echo "Deleting file X from .trashCan permenently"

}

function init_monitor_sh(){

	#Start a new monitor process
		
	#invoke a new window with the monitor process running...

	PID=$(ps -x | grep monitor.sh | grep "[0-9]*.Ss+" | awk '{print $1}')

	if [[ $PID -gt 0 ]];then
		echo "The monitor script is running..."
	else
		gnome-terminal --command './monitor.sh' --hide-menubar --title="MONITOR" > .termout
	fi

}


function display_tc_usage(){

	echo "Display .trashCan total usage..."

}



#script start execution from main function call below. 

main $@




#____________________________  END OF safeDel.sh SCRIPT  _________________________________


