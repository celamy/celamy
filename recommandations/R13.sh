#!/bin/bash

echo -e "\nRecommandation 13 : Créer un système de stockage pour les données non persistantes\n\n"
echo -e "Recommandation : \nMonter les répertoires contenant des données non persistantes ou temporaires en utilisant tmpfs mount"

echo -e "\n\nRemédiation : \nL'option --mount permettra de préciser le type et la destination du montage, la taille et le mode du tmpfs mais ces deux dernières ne sont pas exigées ('docker run -d -it --name tmptest --mount type=tmpfs,destination=/app,tmpfs-type=340m,tmpfs-mode=1770 nginx:latest')"

echo -e "\n\nAudit : "
echo -e "\n- Vérification de l'existence du système de stockage :"
grep tmpfs /proc/mounts

echo -e "\n\nFin de la recommandation 13.\n"
