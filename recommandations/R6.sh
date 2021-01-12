#!/bin/bash

echo -e "\nRecommandation 6 : Dédier des namespaces PID, IPC et UTS pour chaque conteneur\n\n"
echo -e "Recommandations : \n- Ne pas démarrer un conteneur avec l'argument --pid=host"
echo -e "- Ne pas démarrer un conteneur avec l'argument --ipc=host"
echo -e "- Ne pas démarrer un conteneur avec l'argument --utc=host"

echo -e "\n\nRemédiation : \nL’option --userns-remap permet de démarrer un conteneur avec son propre namespace USER ID"

echo -e "\n\nAudit : Si une des vérifications retourne 'host' alors le namespace sera partagé entre les conteneurs. "
echo -e "\n- Vérification du partage de Host PID namespace :"
docker ps --quiet --all | xargs docker inspect --format '{{ .Id }}: PidMode={{ .HostConfig.PidMode }}'
echo -e "\n- Vérification du partage de Host IPC :"
docker ps --quiet --all | xargs docker inspect --format '{{ .Id }}: IpcMode={{ .HostConfig.IpcMode }}'
echo -e "\n- Vérification du partage de Host UTS :"
docker ps --quiet --all | xargs docker inspect --format '{{ .Id }}: UTSMode={{ .HostConfig.UTSMode }}'
echo -e "\n\nFin de la recommandation 6.\n"
