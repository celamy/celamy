#!/bin/bash


. /home/pfe/menu/presentation.sh --source-only

#####################################################################################################################################################################
#####################################################################################################################################################################
#####################################################                                                    ############################################################
#####################################################              Menu audit un seul docker             ############################################################
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


if [[ $1 != "" ]]; then
	name=$1
	image=$2
else
	# read du nom de docker
	read -p "Nom du docker à chercher : " name

	# recherche du docker
	result_search=`docker ps --format '{{.Names}}' | grep "\<$name\>"`

	echo "GREP : $result_search"

	# est-ce qu'il existe
	if [[ $result_search == "" ]]; then
		echo "Nom non renseigné, essayez à nouveau"
		echo -e "\n\n${PINK}Si cela peut aider, voici la liste des conteneurs existants${WHITE}"
        	docker ps
		$MENU_AUDIT_UN_DOCKER
		exit 3
	else
		echo "NAME : $name"
		recherche=`docker ps --format '{{.Image}};{{.Names}}' | grep "$name"`
		image=`echo $recherche | sed 's/;.*//'`
	fi
fi

# aficher l'image de présentation
banniere_sous_menu


echo -e "${DARK_CYAN}Audit d'un docker"
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
        echo "Toutes les analyses complètes image: $image nom: $name"
        # appels des fonctions
        $DOCKERFILES_DIRECTORIES $image

	echo -e "\n${YELLOW}                                            Appuyez sur une touche pour continuer.."
        read -n 1 -s

        $ANALYSE_IMAGE $image

	echo -e "\n${YELLOW}                                            Appuyez sur une touche pour continuer.."
        read -n 1 -s
	tput sgr0

        $ANSSI $name
	tput sgr0

	#affichage d'une actualité
        $CONSEILS
        tput sgr0

        # retour au menu
        echo -e "\n${YELLOW}                                            Appuyez sur une touche pour terminer.."
        read -n 1 -s
        $MENU_AUDIT_UN_DOCKER $name $image
        exit 3

elif [[ $output1 == 2 ]]; then
        # analyse des images
        clear
        echo "Analyse de l'image $image"
        # appels des fonctions
	$ANALYSE_IMAGE $image

	#affichage d'une actualité
        $CONSEILS
        tput sgr0

        # retour au menu
        echo -e "\n${YELLOW}                                            Appuyez sur une touche pour terminer.."
        read -n 1 -s
        $MENU_AUDIT_UN_DOCKER $name $image
        exit 3

elif [[ $output1 == 3 ]]; then
        # analyse des images
        clear
        echo "Analyse des droits de $image"
        # appels des fonctions
	$DOCKERFILES_DIRECTORIES $image

	#affichage d'une actualité
        $CONSEILS
        tput sgr0

        # retour au menu
        echo -e "\n${YELLOW}                                            Appuyez sur une touche pour terminer.."
        read -n 1 -s
        $MENU_AUDIT_UN_DOCKER $name $image
        exit 3

elif [[ $output1 == 4 ]]; then
        # recommendations de l'ANSSI
        clear
        echo "Recommendations de l'ANSSI"
        # appels des fonctions
	$ANSSI $name

	#affichage d'une actualité
        $CONSEILS
        tput sgr0

        # retour au menu
        echo -e "\n${YELLOW}                                            Appuyez sur une touche pour terminer.."
        read -n 1 -s
        $MENU_AUDIT_UN_DOCKER $name $image
        exit 3

elif [[ $output1 == 5 ]]; then
        # retour menu principal
        clear
        $MENU_PRINCIPAL
        exit 2
else
        # on revient ici
        clear
        $MENU_AUDIT_UN_DOCKER $name $image
        exit 3
fi

exit 3

