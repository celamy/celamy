#!/bin/bash

IMAGE=$1

echo -e "\n\n##### ANALYSE DE L'IMAGE $IMAGE #####\n"

# Utilisateur utilisé par l'image
sortie=$(docker run --rm $IMAGE whoami)
echo -e "Utilisateur utilisé par l'image : ${sortie}"
if [[ "$sortie" == "root" ]]
then
	echo -e "L'utilisateur root doit être modifié. Le principe de moindre privilèges doit être appliqué."
fi
sortie=$(docker run --rm $IMAGE id)
echo -e "Droits de l'utilisateur utilisé par l'image : ${sortie}"

# Tag utilisé
if [[ "$IMAGE" == *":latest" ]]
then
	echo -e "Vérification du tag : le tag latest est à éviter $IMAGE, le tag doit être renseigné"
elif [[ "$IMAGE" != *":"* ]]
then
	echo -e "Vérification du tag : le tag doit être renseigné $IMAGE:<tag>"
else
	echo -e "Vérification du tag : l'utilisation du tag est appropriée"
fi
echo -e ""

## Vulnérabilités de l'image
echo -e "Analyse des vulnérabilités de l'image"
echo -e ""
echo -e "Vulnérabilités dues à l'OS :"
trivy image --vuln-type os --severity HIGH,CRITICAL $IMAGE
echo -e ""
echo -e "Vulnérabilités dues aux librairies :"
trivy image --vuln-type library --severity HIGH,CRITICAL $IMAGE
echo -e "\n\n"
