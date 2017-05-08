#!/bin/bash

#elaborato Shell 
#Autore: Ghignoni Eros
#Matricola: VR397407

fileInput=$1

#ordino per LAN, in modo da semplificare la visualizzazione all'utente
sort -d -f -o $fileInput.csv $fileInput.csv

while read line; 
do

	firstCol=`echo $line | cut -d ';' -f1`			#LAN
	secondCol=`echo $line | cut -d ';' -f2`			#MAC

	echo "$firstCol => $secondCol"

	
done < $fileInput.csv

echo ""
echo ""
echo "Premere INVIO"
read

exit