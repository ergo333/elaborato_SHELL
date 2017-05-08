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
#e' una FSM

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

			networks+=($lan)		#indice della LAN
			macAddresses+=($mac)	#append del MAC address
			rows+=($countRows)		#numero riga del MAC		
	
		fi
	fi

done < $fileInput   #redirect file come input del ciclo 

esiste=1

#ciclo che controlla l'esistenza del MAC inserito. -> fintantochè non lo inserisci correttamente

while [ $esiste -eq 1 ]
do
	echo ""
	echo ""
	echo "Inserisci il MAC address da modificare (48 bit esadecimale)"
	read oldMac
	echo ""

	contaUguali=0
	macIndexes=()			#contiene l'indice del vettore dei MAC address
	i=0
	for address in "${macAddresses[@]}";		#itero per tutti gli elementi dell'array
	do
		
		if [ "$address" = "$oldMac" ] ; then

			contaUguali=$((contaUguali+1))				#conto i MAC address uguali 
			echo "$contaUguali) LAN"${networks[$i]}" => "$address
			macIndexes+=($i)
			esiste=0			#MAC corretto

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
while [ $valido -eq 0 ]   #fintantoche' non trovo un MAC non ancora utilizzato
do 
	
	i=0
	generatedMAC=""
	while [ $i -lt 12 ]; #genero i 12 'caratteri' dell'indirizzo MAC
	do

		rand=`echo $((RANDOM%16))`   #RANDOM: variabile casuale -> da 0 a 15
		case $rand in
			10) generatedMAC="$generatedMAC"A;;
			11) generatedMAC="$generatedMAC"B;; 
			12) generatedMAC="$generatedMAC"C;;
			13) generatedMAC="$generatedMAC"D;;
			14) generatedMAC="$generatedMAC"E;;
			15) generatedMAC="$generatedMAC"F;;
			*) generatedMAC=$generatedMAC"$rand";;

		esac
		i=$((i+1))
	done	

	valido=1

	checkEsistenza $generatedMAC ${networks[${macIndexes[$iMAC]}]} $fileDB  #passo l'indice della LAN 
	occupato=$?   #valore di ritorno della funzione: 0 e' gia' utilizzato, 1 altrimenti

	if [ $occupato -eq 0 ]; then
		valido=0
	fi

done

echo ""
echo "L'indirizzo inserito risulta corretto"

echo ""
echo $generatedMAC

#aggiungo in coda al file csv il nuovo MAC address
appendDB $generatedMAC ${networks[${macIndexes[$iMAC]}]} $fileDB

#sostituisco la il MAC address "vecchio" con quello nuovo 
replaceLine $oldMac $generatedMAC ${rows[${macIndexes[$iMAC]}]} $fileInput

echo ""
echo "Modifica avvenuta!"
echo ""
echo "Premere INVIO per terminare"

read



