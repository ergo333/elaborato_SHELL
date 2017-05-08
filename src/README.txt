Elaborato BASH  -  Sistemi Operativi 			UNIVR

Il programma è suddiviso in 5 sorgenti:
	- vboxMAC.sh: è il main
	- show_MAC_vbox.sh: contiene la funzione che visualizza i MAC address presenti nel file .vbox
	- show_MAC_DB.sh: contiene la funzione che visualizza i MAC utilizzati, presenti nel file DB
	- modifica_MAC.sh: contiene la funzione che permette di modificare il MAC address
	- auto_MAC.sh: contiene la funzione che modifica in modo automatico il MAC address selezionato


Il file database viene creato automaticamente (se non è già esistente) all'inizio del programma (main).

Il file guida.txt contiene il messaggio d'errore che viene stampato quando l'utente non passa i parametri correttamente

Considerazioni personali:
	1) 	Nel file .vbox sono presenti più network, ognuna delle quali contiene un numero arbitrario di MAC address. Network diverse possono contenere lo
		stesso indirizzo MAC. Quando l'utente chiede di modificare un MAC address, il programma mostra una schermata che elenca tutte le LAN che contengono il MAC digitato. 
		L'utente potra' quindi scegliere il MAC address da modificare, a seconda della LAN di appartenenza. 

	2) 	Il file database è un file .csv -> LAN[n° networsk];MACADDRESS;

	3) 	Il MAC address deve essere del seguente formato: [0-9A-Z] -> per 12 caratteri -> non è case sensitive

	4) 	All'inizio, il programma è in grado di riconoscere se è già stato creato o meno il file DB (.csv). 
		Se il DB è già presente, il programma non farà nulla, altrimenti ne creerà uno nuovo contenente tutti i MAC address presenti nel file .vbox
		passato come parametro.


Progetto svolto da: 
			GHIGNONI EROS		VR397407