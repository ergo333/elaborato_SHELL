#!/bin/bash

#elaborato Shell 
#Autore: Ghignoni Eros
#Matricola: VR397407


source utils.sh


#visualizzo a schermo i MAC da modificare
fileInput=$1
fileDB=$2
	
lan=1			#indice della LAN
newLan=1		#indica che siamo dentro una LAN 

macAddresses=() #vettore contenente tutti i MAC del file .vbox
networks=()		#vettore contenente per ogni MAC la rete di appartenenza
rows=()			#vettore che contiene, per ogni MAC, la riga del vbox (semplifica la sostituzione nel file)
countRows=0

echo ""
echo ""

while read line;
do	
	countRows=$((countRows+1))

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

		if p=`echo $line | grep -o -i "MACAddress=\"[A-Z0-9]*\""`; then

			mac=`echo $p | cut -d"\"" -f2`

			#aggiungo in fondo al DB il nuovo MAC address
			echo "LAN"$lan" => "$mac 

			networks+=($lan)		#contiene il numero della LAN di appartenenza del MAC address
			macAddresses+=($mac)	#append del mac address
			rows+=($countRows)		#contiene la riga del file che contiene il MAC address
	
		fi
	fi

done < $fileInput   #redirect file come input del ciclo 

esiste=1

while [ $esiste -eq 1 ]		#fintantoche' non trovo il MAC inserito, continuo a richiedere l'input
do
	echo ""
	echo ""
	echo "Inserisci il MAC address da modificare (48 bit esadecimale -> 12 caratteri)"
	read oldMac
	echo ""

	contaUguali=0
	macIndexes=()		#contiene l'indice del vettore dei MAC 
	i=0
	for address in "${macAddresses[@]}";		#itero per tutti gli elementi dell'array
	do
		if [ "$address" = "$oldMac" ] ; then

			contaUguali=$((contaUguali+1))
			echo "$contaUguali) LAN"${networks[$i]}" => "$address
			macIndexes+=($i)
			esiste=0

		fi

		i=$((i+1))
	done

	if [ ${#macIndexes[@]} -eq 0 ]; then    #non e' stato trovato nel vbox
		echo "Il MAC inserito non esiste nel file vbox!"
	fi

done

#mostro all'utente l'elenco delle lan che contengono quell'indirizzo
iMAC=0
if [ ${#macIndexes[@]} -gt 1 ]; then   #se sono stati trovati piu' mac, l'utente puo' scegliere la LAN

	while [ $iMAC -lt 1 ] || [ $iMAC -gt ${#macIndexes[@]} ]
	do

		echo ""
		echo "Inserire l'indice del MAC selezionato"
		read iMAC
	done

else

	iMAC=1		#contiene l'indice del MAC selezionato -> e' ovviamente il primo 
fi

iMAC=$((iMAC-1))	

echo ""
echo ""

valido=0
while [ $valido -eq 0 ]			#continuo a richiedere finche' non viene inserito un MAC corretto
do 
	echo "Inserisci il nuovo MAC address"
	read newMac
	
	checkValidita $newMac

	valido=$?	#$? valore di ritorno (exit) della funzione

	if [ $valido -eq 0 ]; then					
		echo "Indirizzo non valido!"

	fi

	#il nuovo MAC address non deve essere presente nel file DB
	
	checkEsistenza $newMac ${networks[${macIndexes[$iMAC]}]} $fileDB  #passo l'indice della LAN
	occupato=$?

	if [ $occupato -eq 0 ]; then
		echo "MAC già utilizzato"
		valido=0
	fi

done

echo ""
echo "L'indirizzo inserito risulta corretto"

#inserisco come ultima riga, il nuovo MAC address nel file DB
appendDB $newMac ${networks[${macIndexes[$iMAC]}]} $fileDB

#sostituisco il vecchio MAC con quello nuovo
replaceLine $oldMac $newMac ${rows[${macIndexes[$iMAC]}]} $fileInput

echo ""
echo "Modifica avvenuta!"
echo ""
echo "Premere INVIO per terminare"
read
exit