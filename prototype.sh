#!/usr/bin/env bash
#Author: Faisal Burhan
#Cpyright (c) Neutron.net
#This script is for testing purpose only.

NAME="Name: Faisal Burhan Abdu"
STUDENT_ID="STUDENT ID: S1719016"



#pattern="$1"

#awk '/'"$pattern"'/ { print FILENAME ":" $0 }' "$@"

function main(){	#______________ BEGIN OF MAIN _____________________________

	echo "$NAME"
	echo "$STUDENT_ID"

	#create a trashCan directory if not exist

	init_trashCan
	
	#check the number of user argument(s) counts to determine if there any inline argument(s) available.

	if [[ $# == 0 ]];then

		#go interactiive mode.

		init_interactive_mode
		
	else
		if [[ ($1 != -l  && $1 != -r && $1 != -m && $1 != -k && $1 != -d && $1 != -t && $1 != "--help") ]];then

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
		
		-m) 
			if [[ $# -gt 1 ]];then
				display_help_menu
			else
				echo "start monitor process"	
			fi	
		;;
		
		-k) 
			if [[ $# -gt 1 ]];then
				display_help_menu
			else
				echo "kill current user's monitor script process"	
			fi
		;;
		
		--help) 
			display_help_menu
		;;
		
		esac


}


function init_interactive_mode(){
	
	USAGE="usage: $0 <fill in correct usage>"

	while getopts :lr:dtmk args #options
	do
  	case $args in
		l) echo "l option";;
     		r) echo "r option; data: $OPTARG";;
     		d) echo "d option";; 
     		t) echo "t option";; 
     		w) echo "m option";; 
     		k) echo "k option";;     
     		:) echo "data missing, option -$OPTARG";;
    		\?) echo "$USAGE";;
  	esac
	done

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
         				"monitor") echo "w";;
         				"kill") echo "k";;
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


#l - list files from .trashCan
#r - recover files from .trashCan to current working directory
#k - kill current monitor process
#d - delete files from .trashCasn directory interactively
#m - start monitoring script
#--help - display help to the user on how to use the script
#t - display total usage of .trashCan directory


function list_files(){

	echo "Listing files from trashCan directory..."
	
	ls -al ~/.trashCan


}

function recover_files(){

	echo "File X will be recovered from .trashCan directory to your current working directory"

	#for TOKEN in $@
	#do
	#	file=$TOKEN

	#	if [[ -f $file ]];then
	#	fi

	#	if [[ -d $file ]];then
	#	fi

	#	if [[ ]];then
	#	else
	#	fi
	#done

}


function kill_monitor_process(){

	echo "Terminating currect running monitor process"

}

function delete_file_intmode(){

	echo "Deleting file X from .trashCan permenently"

}

function init_monitor_sh(){

	echo "Start a new monitor process"

}


function display_tc_usage(){

	echo "Display .trashCan total usage..."

}



#script start execution from main function call below. 

main $@


#____________________________  END OF safeDel.sh SCRIPT  _________________________________


