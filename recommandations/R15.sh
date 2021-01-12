#!/bin/bash

echo -e "\nRecommandation 15 : Resteindre l'accès aux répertoires et aux fichiers sensibles\n\n"

echo -e "Remédiation : Ne pas démarrer le conteneur qui possède des répertoires ou fichiers sensibles sans le mode lecture-écriture"

echo -e "\n\nAudit : Retourne la liste des répertoires et de leur mode de montage"
echo -e "\n- Vérification du mode des répertoires pour chaque instance du conteneur :"
docker ps --quiet --all | xargs docker inspect --format '{{ .Id }}: Volumes={{ .Mounts }}'

echo -e "\n\nFin de la recommandation 15.\n"
