#!/bin/bash

#elaborato Shell 
#Autore: Ghignoni Eros
#Matricola: VR397407

function checkEsistenza(){

	while read line; 
	do
		firstCol=`echo $line | cut -d ';' -f1`
		secondCol=`echo $line | cut -d ';' -f2`

		lanIndex=`echo $firstCol | cut -d 'N' -f2`
		if [ "$secondCol" = "$1" ] && [ $2 -eq $lanIndex ]; then	#MAC gia' utilizzato
			return 0
		fi
		
	done < $3.csv

	return 1		#MAC non ancora utilizzzato

}

function appendDB(){
	echo "LAN"$2";"$1";" >> $3.csv
}

function replaceLine(){
		
	sed -i -e $3's/MACAddress="'$1'"/MACAddress="'$2'"/' $4
			
}

#controlla se il MAC inserito segue il pattern
function checkValidita(){
	if [ ${#1} -eq 12 ]; then   #se la lunghezza della stringa è 12
	
		if res=`echo $1 | grep -i "[0-9A-F]\{12\}"`; then  #\ -> { carattere speciale
														   #i ignore case
			return 1
		else
			return 0
		fi
	else
		return 0
	fi
}