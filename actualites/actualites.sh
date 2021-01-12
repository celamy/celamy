#!/bin/bash

echo -e "${DARK_CYAN}Voici les dernières actualites :${WHITE}\n\n"
        #On prépare l'environnement

	#On récupère les informations sur les sites
	curl -s https://www.lemondeinformatique.fr/toute-l-actualite-marque-sur-docker-1477.html > /home/pfe/actualites/lmi.txt
	curl -s https://www.silicon.fr/tag/docker > /home/pfe/actualites/silicon.txt

	#On exécute les scripts pour avoir l'actualité sur les site silicon.fr et lemondeinformatique.fr
	/home/pfe/actualites/silicon.sh
	/home/pfe/actualites/lmi.sh

	#On clean les balises HTML pour bien les afficher
	#hxunent -f actualites/actualites.txt > actualites/actualites.txt

        while [ -z $affichage ] || [ $affichage == "O" ] || [ $affichage == "o" ]; do
                #On affichage au hasard 5 lignes du fichier qui contient la sortie des deux sh précédents
		tput sgr0
                shuf -n 5 /home/pfe/actualites/actualites.txt
                echo -e "${DARK_CYAN}\n\nSouhaitez-vous voir d'autres actualités ? (O|N)${YELLOW} \c"
                read affichage
                if [ $affichage != "O" ] && [ $affichage != "N" ]; then
                        echo "\n${DARK_CYAN}Veuillez resaisir votre choix (O|N) : \c ${WHITE}"
                        read affichage
                fi
        done
        # retour menu principal
        echo -e "\n${YELLOW}                                            Appuyez sur une touche pour terminer.."
        read -n 1 -s
