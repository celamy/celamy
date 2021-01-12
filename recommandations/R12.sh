#!/bin/bash

echo -e "\nRecommandation 12 : Restreindre en lecture le système de fichiers racine de chaque conteneur et limiter l'écriture de l'espace de stockage des contenurs\n\n"
echo -e "Recommandations : \n- Démarrer chaque conteneur avec son système de fichiers racine en lecture seule avec l'option -read-only"
echo -e "- Démarrer un conteneur avec une limite maximale d'utilisation de l'espace disque de l'hôte en lecture et écriture avec l'option -storage-opt"
echo -e "- Démarrer un conteneur avec son système de fichier racine dès lors que la zone de stockage local de Docker (/var/lib/docker/) est une partition dédiée et distinctes des partitions de l'hôte"

echo -e "\n\nRemédiation : \nIl est possible de modifier directement dans le fichier de configuration de docker la variable \"storage-opts\" en indiquant sa taille (size=50GB par exemple)"

echo -e "\n\nAudit : Le premier audit doit retourner false, et le second ne doit pas afficher \"storage-opt\""
echo -e "\n- Vérification de la lecture seule :"
docker ps --quiet --all | xargs docker inspect --format '{{ .Id }}: ReadonlyRootfs={{ .HostConfig.ReadonlyRootfs }}'

echo -e "\n- Vérification de l'utilisation de la limite d'écriture :"
ps -ef | grep dockerd

echo -e "\n\nFin de la recommandation 12.\n"
