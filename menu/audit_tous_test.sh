#!/bin/bash

. /home/celamy/celamy/menu/presentation.sh --source-only

#####################################################################################################################################################################
#####################################################################################################################################################################
#####################################################                                                    ############################################################
#####################################################             Menu audit tous les dockers            ############################################################
#####################################################                                                    ############################################################
#####################################################################################################################################################################
#####################################################################################################################################################################

# Installation de Trivy si nécessaire
sortie=$(trivy)
if [[ "$sortie" == "" ]]
then
	apt-get install wget apt-transport-https gnupg lsb-release -y
	wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
	echo deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main | sudo tee -a /etc/apt/sources.list.d/trivy.list
	sudo apt-get update -y
	sudo apt-get install trivy -y
else
	echo "Trivy est déjà installé"
fi

# Extraction des conteneurs déployés
touch running_containers.csv
docker ps --format '{{.Names}};{{.Image}}' > running_containers.csv


# aficher l'image de présentation
banniere_sous_menu_tous


echo -e "${DARK_CYAN}Audit de tous les conteneurs dockers"
echo -e "${WHITE}               1. Audit complète"
echo -e "               2. Analyse des images"
echo -e "               3. Analyse des droits"
echo -e "               4. Recommendations de l'ANSSI"
echo -e "               5. Retour au menu principal.."

read output1

tput sgr0


if [[ $output1 == 1 ]]; then
	# toutes les audits
        clear
        echo "Toutes les analyses complètes"
	cat running_containers.csv
        # appels des fonctions
	while IFS=';' read name image
	do

		$DOCKERFILES_DIRECTORIES $image
		tput sgr0
	done < running_containers.csv

	echo -e "\n${YELLOW}                                            Appuyez sur une touche pour continuer.."
        read -n 1 -s

	tput sgr0

        while IFS=';' read name image
	do
		$ANSSI $name
		tput sgr0

		$ANALYSE_IMAGE $image
		tput sgr0

	done < running_containers.csv

	echo -e "\n${YELLOW}                                            Appuyez sur une touche pour continuer.."
        read -n 1 -s

	tput sgr0

	#affichage d'une actualité
	$CONSEILS
	tput sgr0


        # retour au menu
        echo -e "\n${YELLOW}                                            Appuyez sur une touche pour terminer.."
        read -n 1 -s
       	$MENU_AUDIT_TOUS_DOCKERS
	exit 3

elif [[ $output1 == 2 ]]; then
        # analyse des images
        clear
        echo "Analyse des images"
        # appels des fonctions
#        $DOCKERFILES_DIRECTORIES 1
 	while IFS=';' read name image
        do

                $ANALYSE_IMAGE $image
                tput sgr0

        done < running_containers.csv

	#affichage d'une actualité
        $CONSEILS
        tput sgr0

	# retour au menu
        echo -e "\n${YELLOW}                                            Appuyez sur une touche pour terminer.."
        read -n 1 -s
        $MENU_AUDIT_TOUS_DOCKERS
	exit 3

elif [[ $output1 == 3 ]]; then
	# analyse des images
        clear
        echo "Analyse des droits"
        # appels des fonctions
	while IFS=';' read name image
	do
		$DOCKERFILES_DIRECTORIES $image
		tput sgr0
	done < running_containers.csv



	#affichage d'une actualité
        $CONSEILS
        tput sgr0

        # retour au menu
        echo -e "\n${YELLOW}                                            Appuyez sur une touche pour terminer.."
        read -n 1 -s
        $MENU_AUDIT_TOUS_DOCKERS
	exit 3

elif [[ $output1 == 4 ]]; then
        # recommendations de l'ANSSI
        clear
        echo "Recommendations de l'ANSSI"
        # appels des fonctions
	 while IFS=';' read name image
        do
                $ANSSI $name
                tput sgr0
        done < running_containers.csv

	#affichage d'une actualité
        $CONSEILS
        tput sgr0

        # retour au menu
        echo -e "\n${YELLOW}                                            Appuyez sur une touche pour terminer.."
        read -n 1 -s
        $MENU_AUDIT_TOUS_DOCKERS
	exit 3


elif [[ $output1 == 5 ]]; then
        # retour menu principal
        clear
        $MENU_PRINCIPAL
	exit 2
else
	# on revient ici
	clear
	$MENU_AUDIT_TOUS_DOCKERS
	exit 3
fi

exit 3
