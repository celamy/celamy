#!/bin/bash

. /home/celamy/celamy/menu/presentation.sh --source-only

#####################################################################################################################################################################
#####################################################################################################################################################################
#####################################################                                                    ############################################################
#####################################################             Menu audit tous les dockers            ############################################################
#####################################################                                                    ############################################################
#####################################################################################################################################################################
####################################################################################################################################################################



# aficher l'image de présentation
banniere_sous_menu


echo -e "${DARK_CYAN}Audit des dockers"
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
        # appels des fonctions
        $DOCKERFILES_DIRECTORIES 1

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
        $DOCKERFILES_DIRECTORIES 1

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
