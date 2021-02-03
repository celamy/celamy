#!/bin/bash

echo -e "${DARK_CYAN}Voici une actualite sur les conteneurs :\n\n"
        #On prépare l'environnement
	tput sgr0
	#On récupère les informations sur les sites
	curl -s https://www.lemondeinformatique.fr/toute-l-actualite-marque-sur-docker-1477.html > $LMITEXT
	curl -s https://www.silicon.fr/tag/docker > $SILITEXT

	#On exécute les scripts pour avoir l'actualité sur les site silicon.fr et lemondeinformatique.fr
	$SILICON
	$LMI

	#On clean les balises HTML pour bien les afficher
	#hxunent -f actualites/actualites.txt > actualites/actualites.txt

	#On affiche au hasard une actualite
	shuf -n 1 $ACTUTEXT

	echo -e "\n\n"
