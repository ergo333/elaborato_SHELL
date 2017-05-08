#!/bin/bash

#elaborato Shell 
#Autore: Ghignoni Eros
#Matricola: VR397407

fileInput=$1
	
lan=1			#indice della LAN
newLan=1		#indica che siamo dentro una LAN 
#e' una FSM

while read line;
do	
	if [ $newLan -eq 1 ]; then #sto cercando una nuova LAN

		if p=`echo $line | grep -i "<[ ]*network[ ]*>"`; then 
			#ogni volta che incontro una nuova network...
			#p contiene "<network>"
			newLan=0
		fi

	else

		if p=`echo $line | grep -i "<[ ]*/[ ]*network[ ]*>"`; then 
			#network terminata

			newLan=1
			lan=$((lan+1))		#incremento il numero di LAN

		fi

		if addr=`echo $line | grep -o -i "MACAddress=\"[A-Z0-9]*\""`; then

			mac=`echo $addr | cut -d"\"" -f2`
			echo "LAN"$lan" => "$mac
		fi

	fi

done < $fileInput   #redirect file come input del ciclo 

echo ""
echo ""
echo "Premere INVIO"
read

exit
