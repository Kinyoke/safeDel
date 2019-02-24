#!/usr/bin/env bash

#move to trashCan dir
cd ~/.trashCan

FILES=$(ls)

	currentFile=$FILES
	f_pointer=0

	declare -a prevFiles

	#if [[ $currentFile == $prevFile ]];then

	#	echo "dir file are the same"

	#else
	#	echo "dir file changed"
		for filename in $currentFile;
		do
			let f_pointer++

			prevFiles[$f_pointer]=$filename

			#echo "$f_pointer: Filename: $filename"

			#echo $currentFile

			#echo $currentFile[2]

		done

		echo ${prevFiles[1]}
	#fi

	#for filename in $FILES;
	#do
		#for ((i=0; i<=$currentFileCount-1; i++));
		#do
	#	f_pointer=`expr $f_pointer + 1`

		#prevFile=($filename)

		#echo $filename | md5sum

    		#done
	#done


#return to previous directory
cd -
