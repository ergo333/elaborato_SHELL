#!/bin/bash

#elaborato Shell 
#Autore: Ghignoni Eros
#Matricola: VR397407

#funzione che stampa a schermo il menu del programma

function menu(){
	echo "MENU (premere il tasto corrispondente all'operazione)"
	echo ""
	echo ""

	echo "1.	Visualizza MAC ADDRESS presenti nel file vbox"
	echo "2.	Visualizza MAC ADDRESS gia' utilizzati"
	echo "3.	Modifica MAC ADDRESS"
	echo "4.	Genera MAC ADDRESS "
	echo "5.	Esci"
}

#funzione che aggiorna il file database contenente tutti i MAC address

function createDB(){

	echo "Aggiornamento DB... "
	fileInput=$1
	fileOutput=$2
	lan=1			#indice della LAN
	newLan=1		#indica che siamo dentro una LAN 
	#e' una FSM

	while read line;
	do	
		if [ $newLan -eq 1 ]; then #sto cercando una nuova LAN

			if p=`echo $line | grep -i "<[ ]*network[ ]*>"`; then 
				#ogni volta che incontro una nuova network...
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
				echo "LAN"$lan";"$mac";" >> $fileOutput.csv
			fi
		fi

	done < $fileInput   #redirect file come input del ciclo 
}

#-------------------------------------------------------------------------------------

#controllo la validita' dei parametri passati in input
if [ "$#" -ne 2 ]; then
	cat guida.txt
	echo ""
	echo ""
	exit	
fi

#parametro 0 = nome dell'eseguibile

if [ ! -e "$1" ]; then #file non esiste
	cat "File not found"
	echo ""
	echo ""
	exit
fi

#se il file DB non esiste lo creo con i dati che possiedo

if [ ! -e "$2".csv ]; then  
	createDB $1 $2
	echo ""

else #se esiste chiedo in input se aggiornare quello vecchio, oppure no

	echo ""
	echo "Premere y per concatenare il database esistente"
	echo "altrimenti per sovrascriverlo"
	read key

	if [ $key != "y" ]; then
		rm $2.csv
		createDB $1 $2
	fi

fi

scelta=0

until [ $scelta -eq 5 ]
do
	menu	#chiamo la funzione che stampa il menu a schermo ed assegno alla variabile la scelta effettuata
	read scelta

	case $scelta in
		1) xterm -e bash show_MAC_vbox.sh $1 &;;
		2) xterm -e bash show_MAC_DB.sh $2 &;;
		3) xterm -e bash modifica_MAC.sh $1 $2&;;
		4) xterm -e bash auto_MAC.sh $1 $2&;;
		5) 	# termino i processi

		  	processes=`pgrep -x xterm` #ottengo il PID dei processi xterm -> quelli che devo chiudere
		  							   #-x indica che il pattern di ricerca è x -> ritorna tutti i pid di xterm
		  	
		   	for p in $processes; do
		   		kill -9 $p 					#kill del processo con PID p
		   	done;;
		*) echo "Errore: scelta non corretta"
	esac


done
exit
