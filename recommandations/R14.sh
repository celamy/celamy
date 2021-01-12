#!/bin/bash

echo -e "\nRecommandation 14 : Créer un système de stockage pour les données persistantes ou partagées\n\n"
echo -e "Recommandation : \n- Monter les répertoires contenant des données persistantes ou partagées en utilisant bind mount"
echo -e "- Monter les répertoires contenant des données persistantes ou partagées en utilisant bind volume"
echo -e "- Si les données ne doivent pas être modifiées par le conteneur, monter les répertoires avec l'option read-only"

echo -e "\n\nRemédiation : \n- L'option --mount permettra de préciser le type et la destination du montage (Pour un bind mount : 'docker run -d -it --name devtest --mount type=bind,source="$(pwd)"/target,target=/app nginx:latest' Pour un bind volume : 'docker run -d --name devtest --mount source=myvol2,target=/app nginx:latest')"

echo -e "\n\nAudit : "
echo -e "\n- Vérification de l'existence du système de stockage (volume) :"
ls /var/lib/docker/volumes
echo -e "\n- Vérification de l'existence du système de stockage (bind mount) :"


echo -e "\n\nFin de la recommandation 14.\n"
