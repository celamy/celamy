#!/bin/bash

vert="\e[32mBonne pratique\e[37m"
jaune="\e[33mAttention\e[37m"
rouge="\e[31mMauvaise pratique\e[37m"
bleu='\e[1;35m'
blanc='\e[1;37m'


#### RECOMMANDATIONS DE L'ANSSI
NAME=$1

BONNE_PRATIQUE=0
MAUVAISE_PRATIQUE=0
ATTENTION=0

echo -e "##### VERIFICATION DES RECOMMANDATIONS DE L'ANSSI $NAME #####"

## R1 à R5 - Cloisonnement du conteneur
echo -e "\n### Recommandations R1 à R5 : Cloisonnement du conteneur ###\n"

# R1 - Isolement des systèmes sensibles de fichiers de l'hôte
echo -e "Recommandation R1 : Isoler les systèmes sensibles de fichiers de l'hôte"
echo -e "Recommandation : Ne pas démarrer un conteneur avec l'argument --privileged"
echo -e "> Vérification de l'absence d'utilisation de l'option privileged :"
sortie=$(docker inspect $NAME | grep '"Privileged": true,')
if [[ "$sortie" != "" ]]
then
	echo -e "$rouge, le conteneur a été démarré avec l'option privileged"
	((MAUVAISE_PRATIQUE++))
else
	echo -e "$vert, l'option privileged n'a pas été utilisée"
	((BONNE_PRATIQUE++))
fi
echo -e ""

# R2 - Restreindre l'accès aux périphériques de l'hôte
echo -e "Recommandation R2 : Restreindre l'accès aux périphériques de l'hôte"
echo -e "Recommandations :\n- Démarrer un conteneur avec l'option --device pour ajouter un périphérique de l'hôte"
echo -e "- Démarrer un conteneur avec les spécifications rwm pour limiter l'accès au strict minimum nécessaire"
echo -e "> Vérification des permissions affectées aux périphériques de l'hôte :"
sortie=$(docker inspect $NAME | egrep '\"Devices\": \[\],')
if [[ "$sortie" == "" ]]
then
	echo -e "$jaune, des permissions sont affectées sur les périphériques. Vérification des permissions par l'utilisateur :"
	echo $sortie | sed 's/.*\"Devices\": \[/Permissions sur les périphériques : /' | sed 's/\],.*//'
	((ATTENTION++))
else
	echo -e "$vert, aucun périphérique n'a été affecté au conteneur"
	((BONNE_PRATIQUE++))
fi
echo -e ""

# R3 - Vérification que le conteneur n'est pas connecté à BRIDGE
echo -e "Recommandation R3 : Interdire la connexion au réseau bridge docker0"
echo -e "Recommandation : Ne pas démarrer un conteneur sur le réseau par défaut bridge"
echo -e "Remédiation : Par défaut docker démarre les conteneurs en les connectant au réseau bridge, docker0, cette option peut être désactivée avec --bridge:none en ligne de commande ou dans le fichier de configuration de docker"
echo -e "> Vérification de l'absence de connexion au réseau bridge :"
sortie=$(docker inspect $NAME -f "{{json .NetworkSettings.Networks }}" | grep "bridge")
if [[ "$sortie" != "" ]]
then 
	sortie=$(docker network ls | grep "bridge")
	if [[ "$sortie" != "" ]]
	then
		echo -e "$rouge, le conteneur est connecté au réseau bridge"
		((MAUVAISE_PRATIQUE++))
	else
		echo -e "$vert, le conteneur est connecté au réseau bridge mais ce dernier n'est pas actif"
		((BONNE_PRATIQUE++))
	fi
else
	echo -e "$vert, le conteneur n'est pas connecté à BRIDGE"
	((BONNE_PRATIQUE++))
fi
echo -e ""

# R4 - Vérification que le conteneur n'est pas connecté à HOST
echo -e "Recommandation R4 : Isoler l'interface réseau de l'hôte"
echo -e "Recommandation : Démarrer un conteneur sans l'option --network host"
echo -e "> Vérification de l'absence de connexion au réseau host :"
sortie=$(docker inspect $NAME -f "{{json .NetworkSettings.Networks }}" | grep "host")
if [[ "$sortie" != "" ]]
then 
	echo -e "$rouge, le conteneur est connecté au réseau host"
	((MAUVAISE_PRATIQUE++))
else
	echo -e "$vert, le conteneur n'est pas connecté au réseau host"
	((BONNE_PRATIQUE++))
fi
echo -e ""

# R5 - Créer un réseau dédié pour chaque connexion réseau
echo -e "Recommandation R5 : Créer un réseau dédié pour chaque connexion réseau"
echo -e "Recommandations :\n- Un réseau doit être crée si un port de l'interface réseau de l'hôte est exposé"
echo -e "- Un réseau doit être crée si le conteneur communique avec d'autres conteneurs"
echo -e "> Vérification des ports exposés :"
docker inspect $NAME --format "{{ .Config.ExposedPorts }}"
echo -e "> Vérification des connexions réseau :"
docker inspect $NAME --format "{{ .NetworkSettings.Networks }}"
echo -e ""

## R6 à R7 - Cloisonnement des ressources
echo -e "\n### Recommandations R6 à R7 : Cloisonnement des ressources ###\n"

# R6 - Dédier des namespaces PID, IPC, et UTS pour chaque conteneur
echo -e "Recommandation R6 : Dédier des namespaces PID, IPC et UTS pour chaque conteneur"
echo -e "Recommandations : \n- Ne pas démarrer un conteneur avec l'argument --pid=host"
echo -e "- Ne pas démarrer un conteneur avec l'argument --ipc=host"
echo -e "- Ne pas démarrer un conteneur avec l'argument --utc=host"
echo -e "Remédiation : L’option --userns-remap permet de démarrer un conteneur avec son propre namespace USER ID"
echo -e "Si une des vérifications retourne 'host' alors le namespace est partagé avec le conteneur..."
echo -e "> Vérification du partage de Host PID namespace :"
sortie=$(docker inspect $NAME --format 'PidMode={{ .HostConfig.PidMode }}' | grep "host")
if [[ "$sortie" != "" ]]
then
	echo -e "$sortie"
	echo -e "$rouge, host est la valeur de PidMode, le namespace est partagé"
	((MAUVAISE_PRATIQUE++))
else
	echo -e "$vert, PidMode n'est pas égal à host"
	((BONNE_PRATIQUE++))
fi
echo -e "> Vérification du partage de Host IPC :"
sortie=$(docker inspect $NAME --format 'IpcMode={{ .HostConfig.IpcMode }}' | grep "host")
if [[ "$sortie" != "" ]]
then
	echo -e "$sortie"
	echo -e "$rouge, host est la valeur de IpcMode, le namespace est partagé"
	((MAUVAISE_PRATIQUE++))
else
	echo -e "$vert, IpcMode n'est pas égal à host"
	((BONNE_PRATIQUE++))
fi
echo -e "> Vérification du partage de Host UTS :"
sortie=$(docker inspect $NAME --format 'UTSMode={{ .HostConfig.UTSMode }}' | grep "host")
if [[ "$sortie" != "" ]]
then
	echo -e "$sortie"
	echo -e "$rouge, host est la valeur de UTSMode, le namespace est partagé"
	((MAUVAISE_PRATIQUE++))
else
	echo -e "$vert, UTSMode n'est pas égal à host"
	((BONNE_PRATIQUE++))
fi
echo -e ""

# R7 - Dédier un namespace USER ID pour chaque conteneur
echo -e "Recommandation R7 : Dédier un namespace USER ID pour chaque conteneur"
echo -e "Recommandations :\n- Le service Docker doit être configuré pour démarrer tous les conteneurs avec un namespace USER ID distinct de l'hôte avec l'option --usernsremap"
echo -e "- Une interdiction de créer de nouveaux namespaces USER ID à l'intérieur du conteneur doit être configurée"

## R8 - Restriction des privilèges
echo -e "\n### Recommmandation R8 : Restriction des privilèges ###\n"

## R8 - Restriction des capabilities
echo -e "Recommandation R8 : Interdire l'utilisation des capabilities"
echo -e "Recommandation : Ne pas démarrer un conteneur avec une capability avec l'option --capdrop=ALL"
echo -e "> Vérification qu'aucune capability n'est utilisée :"
sortie=$(docker inspect $NAME | egrep "CapAdd\": null,")
if [[ "$sortie" == "" ]]
then
	sortie=$(docker inspect $NAME)
	echo -e "$jaune, aucune capability ne doit être donnée à un conteneur à moins qu'elle ne soit nécessaire :"
	echo $sortie | sed 's/.*\"CapAdd\": \[/Capabilities affectés : /g' | sed 's/\],.*//g'
	((ATTENTION++))
else
	echo -e "$vert, aucune capability n'a été affectée"
	((BONNE_PRATIQUE++))
fi
echo -e ""


## R9 à R15 - Limitation des accès aux ressources

echo -e "\n### Recommandations R9 à R15 : Limitation des accès aux ressources ###\n"

# R9 - Dédier les Control Groups pour chaque conteneur (pas d'utilisation de --cgroup-parent)
echo -e "Recommandation R9 : Dédier les Control groups pour chaque conteneur"
echo -e "Recommandations :\n- Démarrer un conteneur avec des Control groups distincts de l'hôte"
echo -e "- Ne pas utiliser l'option --cgroup-parent"
echo -e "> Vérification que les Control groups utilisés sont distincts de l'hôte :"
sortie=$(docker inspect $NAME | egrep '\"CgroupParent\": \"\",')
if [[ "$sortie" == "" ]]
then
	sortie=$(docker inspect $NAME)
	echo -e "$rouge, l'utilisation de Control groups non distints de l'hôte ont été trouvés :"
	echo $sortie | sed 's/.*\"CgroupParent\":/CgroupParent :/g' | sed 's/\, \"BlkioWeight\".*//g'
	((MAUVAISE_PRATIQUE++))
else
	echo -e "$vert, aucun Control group parent n'est utilisé par le conteneur"
	((BONNE_PRATIQUE++))
fi
echo -e ""

# R10 - Options --memory et --memory-swap pour limiter l'utilisation de la mémoire
echo -e "Recommandation R10 : limiter l'utilisation de la mémoire de l'hôte pour chaque conteneur"
echo -e "Recommandations :\n- Démarrer un conteneur avec une limite maximale d'utilisation de la mémoire de l'hôte avec l'option --memory"
echo -e "- Démarrer un conteneur avec une limite maximale d'utilisation de la mémoire swap de l'hôte avec --memory-swap"
echo -e "> Vérification qu'une limite maximale de la mémoire de l'hôte a été fixée :"
sortie_memory=$(docker inspect $NAME --format '{{ .HostConfig.Memory }}' | egrep "(^0)")
if [[ "$sortie_memory" == "" ]]
then
	echo -e "$vert, une limite maximale de l'utilisation de la mémoire de l'hôte est définie :"
	docker inspect $NAME --format 'Mémoire : {{ .HostConfig.Memory }}'
	((BONNE_PRATIQUE++))
else
	echo -e "$rouge, aucune limite de l'utilisation de la mémoire de l'hôte n'a été définie"
	((MAUVAISE_PRATIQUE++))
fi
echo -e "> Vérification qu'une limite maximale de la mémoire swap de l'hôte a été fixée :"
sortie_swap=$(docker inspect $NAME --format '{{ .HostConfig.MemorySwap }}' | egrep "(^0)")
if [[ "$sortie_swap" == "" ]]
then
	echo -e "$vert, une limite maximale de l'utilisation de la mémoire swap de l'hôte est définie :"
	docker inspect $NAME --format 'Mémoire swap : {{ .HostConfig.MemorySwap }}'
	((BONNE_PRATIQUE++))
else
	echo -e "$rouge, aucune limite de l'utilisation de la mémoire swap de l'hôte n'a été définie"
	((MAUVAISE_PRATIQUE++))
fi
echo -e ""

# R11 - Options --cpus ou --cpu-period et --cpu-quota pour limiter l'utilisation du cpu
echo -e "Recommandation R11 : Limiter l'utilisation du CPU de l'hôte pour chaque conteneur"
echo -e "Recommandations :\n- Démarrer un conteneur avec une limite maximale d'utilisation du CPU de l'hôte"
echo -e "- Utiliser l'option --cpus ou les options --cpu-period et cpu-quota"
echo -e "> Vérification d'une limite d'utilisation du CPU de l'hôte :"
sortie_CPU=$(docker inspect $NAME | egrep '\"NanoCpus\": 0,')
sortie_CPU_PERIOD=$(docker inspect $NAME | egrep '\"CpuPeriod\": 0,')
sortie_CPU_QUOTA=$(docker inspect $NAME | egrep '\"CpuQuota\": 0,')
if [[ "$sortie_CPU" == "" ]]
then
	sortie=$(docker inspect $NAME)
	echo -e "$vert, une limite de l'utilisation du CPU a été configurée :"
	echo $sortie | sed 's/.*\"NanoCpus\":/CPU :/g' | sed 's/,.*//g'
	((BONNE_PRATIQUE++))
elif [[ "$sortie_CPU_PERIOD" == "" && "$sortie_CPU_QUOTA" == "" ]]
then
	echo -e "$vert, une limite de l'utilisation du CPU a été configurée :"
	sortie=$(docker inspect $NAME)
	echo $sortie | sed 's/.*\"CpuPeriod\":/CPU Period :/g' | sed 's/\"CpuQuota\":/CPU Quota :/g' | sed 's/, \"CpuRealtimePeriod\".*//g'
	((BONNE_PRATIQUE++))
else
	echo -e "$rouge, aucune limite d'utilisation du CPU n'a été configurée"
	((MAUVAISE_PRATIQUE++))
fi
echo -e ""

# R12 : Restreindre en lecture le système de fichiers racine de chaque conteneur et limiter l'écriture de l'espace de stockage des contenurs
echo -e "Recommandation R12 : Restreindre en lecture le système de fichiers racine de chaque conteneur et limiter l'écriture de l'espace de stockage des contenurs"
echo -e "Recommandations : \n- Démarrer chaque conteneur avec son système de fichiers racine en lecture seule avec l'option -read-only"
echo -e "- Démarrer un conteneur avec une limite maximale d'utilisation de l'espace disque de l'hôte en lecture et écriture avec l'option -storage-opt"
echo -e "- Démarrer un conteneur avec son système de fichier racine dès lors que la zone de stockage local de Docker (/var/lib/docker/) est une partition dédiée et distinctes des partitions de l'hôte"
echo -e "Remédiation : Il est possible de modifier directement dans le fichier de configuration de docker la variable \"storage-opts\" en indiquant sa taille (size=50GB par exemple)"
echo -e "La première vérification doit retourner false, et le second ne doit pas afficher \"storage-opt\""
echo -e "> Vérification de la lecture seule :"
sortie=$(docker inspect $NAME --format 'ReadonlyRootfs={{ .HostConfig.ReadonlyRootfs }}' | grep "false")
if [[ "$sortie" == "" ]]
then
	echo -e "$sortie"
	echo -e "$rouge, false n'est pas la valeur retournée pour ReadonlyRootfs, le système de fichiers racine n'est pas en lecture seule"
	((MAUVAISE_PRATIQUE++))
else
	echo -e "$vert, le système de fichiers racine est en lecture seule, ReadonlyRootfs retourne false"
	((BONNE_PRATIQUE++))
fi
echo -e "> Vérification de l'utilisation de la limite d'écriture :"
ps -ef | grep dockerd
echo -e ""

# R13 : Créer un système de stockage pour les données non persistantes
echo -e "Recommandation R13 : Créer un système de stockage pour les données non persistantes"
echo -e "Recommandation : Monter les répertoires contenant des données non persistantes ou temporaires en utilisant tmpfs mount"
echo -e "Remédiation : L'option --mount permettra de préciser le type et la destination du montage, la taille et le mode du tmpfs mais ces deux dernières ne sont pas exigées ('docker run -d -it --name tmptest --mount type=tmpfs,destination=/app,tmpfs-type=340m,tmpfs-mode=1770 nginx:latest')"
echo -e "> Vérification de l'existence du système de stockage :"
grep tmpfs /proc/mounts
echo -e ""

# R14 : Créer un système de stockage pour les données persistantes ou partagées
echo -e "Recommandation R14 : Créer un système de stockage pour les données persistantes ou partagées"
echo -e "Recommandations : \n- Monter les répertoires contenant des données persistantes ou partagées en utilisant bind mount"
echo -e "- Monter les répertoires contenant des données persistantes ou partagées en utilisant bind volume"
echo -e "- Si les données ne doivent pas être modifiées par le conteneur, monter les répertoires avec l'option read-only"
echo -e "Remédiation : L'option --mount permettra de préciser le type et la destination du montage (Pour un bind mount : 'docker run -d -it --name devtest --mount type=bind,source="$(pwd)"/target,target=/app nginx:latest' Pour un bind volume : 'docker run -d --name devtest --mount source=myvol2,target=/app nginx:latest')"
echo -e "> Vérification de l'existence du système de stockage (volume) :"
ls /var/lib/docker/volumes
echo -e ""

# R15 : Resteindre l'accès aux répertoires et aux fichiers sensibles
echo -e "Recommandation R15 : Resteindre l'accès aux répertoires et aux fichiers sensibles"
echo -e "Remédiation : Ne pas démarrer le conteneur qui possède des répertoires ou fichiers sensibles sans le mode lecture-écriture"
echo -e "> Vérification du mode des répertoires pour chaque instance du conteneur :"
docker inspect $NAME --format 'Volumes={{ .Mounts }}'
echo -e ""

echo -e "Nombre de $vert : $BONNE_PRATIQUE"
echo -e "Nombre de $jaune : $ATTENTION"
echo -e "Nombre de $rouge : $MAUVAISE_PRATIQUE"
echo -e "\n\n"
