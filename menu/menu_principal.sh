#!/bin/bash

. /home/pfe/menu/presentation.sh --source-only

#####################################################################################################################################################################
#####################################################################################################################################################################
#####################################################					 		 ############################################################
#####################################################		     	 Menu principal			 ############################################################
#####################################################							 ############################################################
#####################################################################################################################################################################
#####################################################################################################################################################################



# aficher l'image de présentation
banniere_menu_principal



echo -e "${DARK_CYAN}Que voulez-vous faire aujourd'hui ?"
echo -e "${WHITE}		1. Audit des conteneurs docker"
echo -e "		2. Audit d'un seul conteneur docker"
echo -e	"		3. Afficher les actualites conteneurs docker"
echo -e "		4. Audit d'après le benchmark conteneur docker du CIS"
echo -e "		5. Quitter.."

echo -e "${YELLOW}"
read output

tput sgr0




if [[ $output == 1 ]]; then
	# audit de tous les dockers
	$MENU_AUDIT_TOUS_DOCKERS
	exit 3

elif [[ $output == 2 ]]; then
	# read du nom de docker
	$MENU_AUDIT_UN_DOCKER
	exit 3

elif [[ $output == 3 ]]; then
	# affichage actualité
	$ACTUALITES
	tput sgr0
	$MENU_PRINCIPAL
        exit 3


elif [[ $output == 4 ]]; then
	# CIS
	clear
        echo "Audit d'après le benchmark docker du CIS (Center of Internet Security)"
	$CIS
	tput sgr0
	echo -e "\n${YELLOW}                                            Appuyez sur une touche pour terminer.."
        read -n 1 -s
	$MENU_PRINCIPAL
	exit 3

elif [[ $output == 5 ]]; then
	banniere_sortie
	tput sgr0
	exit 2
else
	$MENU_PRINCIPAL
	exit 3
fi	

tput sgr0  
exit 3
