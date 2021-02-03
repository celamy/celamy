#!/bin/bash

echo -e "${DARK_CYAN}Voici les dernières actualites :${WHITE}\n\n"
        #On prépare l'environnement

	#On récupère les informations sur les sites
	curl -s https://www.lemondeinformatique.fr/toute-l-actualite-marque-sur-docker-1477.html > $LMITEXT
	curl -s https://www.silicon.fr/tag/docker > $SILITEXT

	#On exécute les scripts pour avoir l'actualité sur les site silicon.fr et lemondeinformatique.fr
	$SILICON
	$LMI

	#On clean les balises HTML pour bien les afficher
	#hxunent -f actualites/actualites.txt > actualites/actualites.txt

        while [ -z $affichage ] || [ $affichage == "O" ] || [ $affichage == "o" ]; do
                #On affichage au hasard 5 lignes du fichier qui contient la sortie des deux sh précédents
		tput sgr0
                shuf -n 5 $ACTUTEXT
                echo -e "${DARK_CYAN}\n\nSouhaitez-vous voir d'autres actualités ? (O|N)${YELLOW} \c"
                read affichage
                if [ $affichage != "O" ] && [ $affichage != "N" ]; then
                        echo -e "\n${DARK_CYAN}Veuillez resaisir votre choix (O|N) : \c ${WHITE}"
                        read affichage
                fi
        done
        # retour menu principal
        echo -e "\n${YELLOW}                                            Appuyez sur une touche pour terminer.."
        read -n 1 -s
