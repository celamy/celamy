#!/bin/bash
#
# Script name: /home/pfe/audit/CIS.sh
#
# Author: Célamy
# Date : 24.12.2020
#
# Description: The following script defines a bunch of docker's audits.
#
# Run Information: This script is run in /home/pfe/menu.
#
# Standard Output: Print the results of the audit


#Déclaration des couleurs
vert="\e[32mFélicitation\e[37m"
jaune="\e[33mAttention\e[37m"
rouge="\e[31mErreur\e[37m"
bleu='\e[1;34m'
cyan='\e[1;36m'
blanc='\e[1;37m'
ok=0
bof=0
err=0

#Déclaration du corps du tableau et affectation du reste des valeurs dans chaque audit
declare -A audit

audit[0,0]="$bleu Audit number$blanc"
audit[0,1]="$bleu\t\t\t\tAudit description$blanc\t\t\t\t\t"
audit[0,2]="$bleu Set correctly$blanc"
audit[0,3]="$bleu Set incorrectly$blanc"
audit[1,0]="$cyan 1.$blanc\t\t"
audit[1,1]="$cyan\t\t\t\tHost configuration$blanc\t\t\t\t\t"
audit[1,2]="      /       "
audit[1,3]="       /        "
audit[2,0]="$cyan 1.1$blanc\t\t"
audit[2,1]="$cyan\t\t\t\tGeneral configuration$blanc\t\t\t\t\t"
audit[2,2]="      /       "
audit[2,3]="       /        "



#1.1.2.1 Ensure that the version of Docker Server is up to date (Not Scored)
audit[3,0]="$cyan 1.1.2.1$blanc\t"
audit[3,1]="$cyan Ensure that the version of Docker Server is up to date$blanc\t\t\t\t"
s_version=`docker version --format '{{.Server.Version}}'`
if [[ $s_version == "19.03.14" ]]; then
	((ok++))
	audit[3,2]="     Yes      "
	audit[3,3]="       /        "
	echo -e "$vert, votre Serveur docker est à jour !"
else
	((bof++))
	audit[3,2]="      /       "
        audit[3,3]="      No        "

	echo -e "$jaune, votre Serveur docker ne possède pas la mise à jour la plus récente !"
fi

#1.1.2.2 Ensure that the version of Docker Client is up to date (Not Scored)
audit[4,0]="$cyan 1.1.2.2$blanc\t"
audit[4,1]="$cyan Ensure that the version of Docker Client is up to date$blanc\t\t\t\t"

c_version=`docker version --format '{{.Client.Version}}'`
if [[ $c_version == "20.10.0" ]]; then
	((ok++))
	audit[4,2]="     Yes      "
        audit[4,3]="       /        "
        echo -e "$vert, votre Client docker est à jour !"
else
	((bof++))
	audit[4,2]="      /       "
        audit[4,3]="      No        "
        echo -e "$jaune, votre Client docker ne possède pas la mise à jour la plus récente ! "
fi

#1.2.2 Ensure only trusted users are allowed to control Docker daemon (Scored)
audit[5,0]="$cyan 1.2.2$blanc\t"
audit[5,1]="$cyan Ensure only trusted users are allowed to control Docker daemon$blanc\t\t\t"
acces=`getent group docker`
if [[ "$acces" =~ (docker|root) ]]; then
	if [[ ${BASH_REMATCH[1]} == "docker" ]]; then
		((ok++))
		audit[5,2]="     Yes      "
        	audit[5,3]="       /        "
		echo -e "$vert, l'utilisateur docker est autorisé à appartenir au groupe docker !"
	elif [[ ${BASH_REMATCH[1]} == "root" ]]; then
		((ok++))
		audit[5,2]="     Yes      "
        	audit[5,3]="       /        "
		echo -e "$vert, l'utilisateur root est autorisé à appartenir au groupe docker !"
	else
		((bof++))
		audit[5,2]="      /       "
	        audit[5,3]="      No        "

		echo -e "$jaune, seuls les utilisateurs root et docker sont autorisés à appartenir au groupe docker. Veuillez supprimer tout autre utilisateur !"
	fi
else
	((err++))
	echo -e "\n$rouge dans l'audit 1.2.2"
fi

#2.1 Ensure network traffic is restricted between containers on the default bridge (Scored)
audit[6,0]="$cyan 2.1\t$blanc\t"
audit[6,1]="$cyan Ensure network traffic is restricted between containers on the default bridge$blanc\t"
bridge=`docker network ls --quiet | xargs docker network inspect --format '{{ .Name }}: {{ .Options }}'`
if [[ "$bridge" =~ com.docker.network.bridge.enable_icc:(true|false) ]]; then
	if [[ ${BASH_REMATCH[1]} == "true" ]]; then
		((bof++))
		audit[6,2]="      /       "
	        audit[6,3]="      No        "
		echo -e "$jaune, la communication 'inter-container' n'a pas été configuré sur votre passerelle par défaut !"
	elif [[ ${BASH_REMATCH[1]} == "false" ]]; then
		((ok++))
		audit[6,2]="     Yes      "
        	audit[6,3]="       /        "
		echo -e "$vert, la communication 'inter-container' est bien configuré sur votre passerelle par défaut !"
	else
		((err++))
		echo -e "$rouge durant l'audit 2.1"
	fi
else
	((err++))
	echo -e "$rouge durant l'audit 2.1"
fi

#2.2 Ensure the logging level is set to info (Scored)
audit[7,0]="$cyan 2.2\t$blanc\t"
audit[7,1]="$cyan Ensure the logging level is set to info$blanc\t\t\t\t\t\t"
level=`ps -ef | grep dockerd`
if [[ "$level" =~ --log-level=(info|[0-7]) ]]; then
        if [[ ${BASH_REMATCH[1]} == "info" ]]; then
 		((ok++))
		audit[7,2]="     Yes      "
        	audit[7,3]="       /        "
		echo -e "$vert, le niveau des logs de docker est obtimal !"
        else
		((bof++))
		audit[7,2]="      /       "
	        audit[7,3]="       /        "
                echo -e "$jaune, le niveau des logs de docker n'est pas optimal, il doit être en 'info' !"
        fi
else
	((ok++))
	audit[7,2]="     Yes      "
        audit[7,3]="       /        "
        echo -e "$vert, le niveau des logs de docker est optimal !"
fi


#2.5 Ensure aufs storage driver is not used (Scored)
audit[8,0]="$cyan 2.5\t$blanc\t"
audit[8,1]="$cyan Ensure aufs storage driver is not used$blanc\t\t\t\t\t\t"
storage=`docker info --format 'Storage Driver: {{ .Driver }}'`
if [[ "$storage" == "Storage Driver: aufs" ]]; then
        ((bof++))
	audit[8,2]="      /       "
        audit[8,3]="      No        "
	echo -e "$jaune, le driver aufs est utilisé comme espace de stockage !"
else
	((ok++))
	audit[8,2]="     Yes      "
        audit[8,3]="       /        "
        echo -e "$vert, le driver aufs n'est pas utilisé comme espace de stockage !"
fi

#2.6 Ensure TLS authentication for Docker daemon is configured (Scored)
audit[9,0]="$cyan 2.6\t$blanc\t"
audit[9,1]="$cyan Ensure TLS authentication for Docker daemon is configured$blanc\t\t\t\t"
tls=`ps -ef | grep dockerd`
if [[ "$tls" =~ (--tlsverify|--tlscacert|--tlscert|--tlskey) ]]; then
	((ok++))
	audit[9,2]="     Yes      "
        audit[9,3]="       /        "
	echo -e "$vert, l'authentification TLS est bien configuré !"
else
	((bof++))
	audit[9,2]="      /       "
        audit[9,3]="      No        "
	echo -e "$jaune, l'authentification TLS n'est pas configuré !"
fi

#2.7 Ensure the default ulimit is configured appropriately (Not Scored)
audit[10,0]="$cyan 2.7\t$blanc\t"
audit[10,1]="$cyan Ensure the default ulimit is configured appropriately$blanc\t\t\t\t"
ulimit=`ps -ef | grep dockerd`
if [[ "$ulimit" == "--default-ulimit" ]]; then
        ((ok++))
	audit[10,2]="     Yes      "
        audit[10,3]="       /        "
	echo -e "$vert, le paramètre ulimit est bien configuré !"
else
	((bof++))
	audit[10,2]="      /       "
        audit[10,3]="      No        "
        echo -e "$jaune, le paramètre ulimit, qui permet de contrôler les ressources disponibles, n'est pas configuré !"
fi

#2.8 Enable user namespace support (Scored)
audit[11,0]="$cyan 2.8\t$blanc\t"
audit[11,1]="$cyan Enable user namespace support\t$blanc\t\t\t\t\t\t"
userns=`docker info --format '{{ .SecurityOptions }}'`
if [[ "$userns" == "userns" ]]; then
        ((ok++))
	audit[11,2]="     Yes      "
        audit[11,3]="       /        "
	echo -e "$vert, le support du namespace des utilisateurs est bien configuré !"
else
	((bof++))
	audit[11,2]="      /       "
        audit[11,3]="      No        "
        echo -e "$jaune, le support du namespace des utilisateurs n'est pas configuré !"
fi

#2.13 Ensure live restore is enabled (Scored)
audit[12,0]="$cyan 2.13$blanc\t"
audit[12,1]="$cyan Ensure live restore is enabled\t$blanc\t\t\t\t\t\t"
live=`docker info --format '{{ .LiveRestoreEnabled }}'`
if [[ "$live" =~ (true|false) ]]; then
	if [[ ${BASH_REMATCH[1]} == "false" ]]; then
		((bof++))
		audit[12,2]="      /       "
        	audit[12,3]="      No        "
		echo -e "$jaune, l'option --live-restore n'est pas activée !"
	elif [[ ${BASH_REMATCH[1]} == "true" ]]; then
                ((ok++))
		audit[12,2]="     Yes      "
        	audit[12,3]="       /        "
		echo -e "$vert, l'option --live-restore est bien activée !"
	else
		((err++))
		echo -e "$rouge durant l'audit 2.13"
	fi
else
	((err++))
	echo -e "\n$rouge durant l'audit 2.13"

fi

#2.16 Ensure that experimental features are not implemented in production (Scored)
audit[13,0]="$cyan 2.16$blanc\t"
audit[13,1]="$cyan Ensure that experimental features are not implemented in production$blanc\t\t"
exp=`docker version --format '{{ .Server.Experimental }}'`
if [[ "$exp" =~ (true|false) ]]; then
        if [[ ${BASH_REMATCH[1]} == "true" ]]; then
                ((bof++))
		audit[13,2]="      /       "
        	audit[13,3]="      No        "
                echo -e "$jaune, les fonctionnalités expérimentales sont activées !"
        elif [[ ${BASH_REMATCH[1]} == "false" ]]; then
                ((ok++))
		audit[13,2]="     Yes      "
        	audit[13,3]="       /        "
                echo -e "$vert, les fonctionnalités expérimentales ne sont pas activées !"
        else
                ((err++))
                echo -e "$rouge durant l'audit 2.16"
        fi
else
        ((err++))
        echo -e "$rouge durant l'audit 2.16"
fi

#2.17 Ensure containers are restricted from acquiring new privileges (Scored)
audit[14,0]="$cyan 2.17$blanc\t"
audit[14,1]="$cyan Ensure containers are restricted from acquiring new privileges$blanc\t\t\t"
pri=`ps -ef | grep dockerd`
if [[ "$pri" =~ --no-new-privileges=false ]]; then
	((ok++))
	audit[14,2]="     Yes      "
        audit[14,3]="       /        "
        echo -e "$vert, les conteneurs ne peuvent acquérir de nouveaux privilèges !"
else
        ((bof++))
	audit[14,2]="      /       "
        audit[14,3]="      No        "
        echo -e "$jaune, les conteneurs peuvent acquérir de nouveaux privilèges !"
fi

#3.1 Ensure that the docker.service file ownership is set to root:root (Scored)
audit[15,0]="$cyan 3.1\t$blanc\t"
audit[15,1]="$cyan Ensure that the docker.service file ownership is set to root:root$blanc\t\t\t"
service=`stat -c %U:%G /lib/systemd/system/docker.service | grep -v root:root`
if [[ -z "$service" ]]; then
	((ok++))
	audit[15,2]="     Yes      "
        audit[15,3]="       /        "
	echo -e "$vert, root est bien propriétaire du service docker !"
else
	((bof++))
	audit[15,2]="      /       "
        audit[15,3]="      No        "
	echo -e "$jaune, root n'est pas le propritétaire du service docker !"
fi


#3.2 Ensure that docker.service file permissions are appropriately set (Scored)
audit[16,0]="$cyan 3.2\t$blanc\t"
audit[16,1]="$cyan Ensure that docker.service file permissions are appropriately set$blanc\t\t\t"
restrict=`stat -c %a /lib/systemd/system/docker.service`
if [[ "$restrict" == "644" ]]; then
        ((ok++))
	audit[16,2]="     Yes      "
        audit[16,3]="       /        "
        echo -e "$vert, le service docker est bien restreint en lecture et écriture seules !"
else
        ((bof++))
	audit[16,2]="      /       "
        audit[16,3]="      No        "
        echo -e "$jaune, le service docker n'est pas restreint en lecture et écriture seules !"
fi

#3.3 Ensure that docker.socket file ownership is set to root:root (Scored)
audit[17,0]="$cyan 3.3\t$blanc\t"
audit[17,1]="$cyan Ensure that docker.socket file ownership is set to root:root$blanc\t\t\t"
socket=`stat -c %U:%G /lib/systemd/system/docker.socket | grep -v root:root`
if [[ -z "$socket" ]]; then
        ((ok++))
	audit[17,2]="     Yes      "
        audit[17,3]="       /        "
        echo -e "$vert, root est bien propriétaire du socket docker !"
else
        ((bof++))
	audit[17,2]="      /       "
        audit[17,3]="      No        "
        echo -e "$jaune, root n'est pas le propritétaire du socket docker !"
fi

#3.4 Ensure that docker.socket file permissions are set to 644 or more restrictive (Scored)
audit[18,0]="$cyan 3.4\t$blanc\t"
audit[18,1]="$cyan Ensure that docker.socket file permissions are set to 644 or more restrictive$blanc\t"
srestrict=`stat -c %a /lib/systemd/system/docker.socket`
if [[ "$srestrict" == "644" ]]; then
        ((ok++))
	audit[18,2]="     Yes      "
        audit[18,3]="       /        "
        echo -e "$vert, le socket docker est bien restreint en lecture et écriture seules !"
else
        ((bof++))
	audit[18,2]="      /       "
        audit[18,3]="      No        "
        echo -e "$jaune, le socket docker n'est pas restreint en lecture et écriture seules !"
fi

#3.5 Ensure that the /etc/docker directory ownership is set to root:root (Scored)
audit[19,0]="$cyan 3.5\t$blanc\t"
audit[19,1]="$cyan Ensure that the /etc/docker directory ownership is set to root:root$blanc\t\t"
directory=`stat -c %U:%G /etc/docker | grep -v root:root`
if [[ -z "$directory" ]]; then
        ((ok++))
	audit[19,2]="     Yes      "
        audit[19,3]="       /        "
        echo -e "$vert, root est bien propriétaire du dossier /etc/docker !"
else
        ((bof++))
	audit[19,2]="      /       "
        audit[19,3]="      No        "
        echo -e "$jaune, root n'est pas le propritétaire du dossier /etc/docker !"
fi

#3.6 Ensure that /etc/docker directory permissions are set to 755 or more restrictively (Scored)
audit[20,0]="$cyan 3.6\t$blanc\t"
audit[20,1]="$cyan Ensure that /etc/docker directory permissions are set to 755 or more restrictively$blanc"
permission=`stat -c %a /etc/docker`
if [[ "$permission" == "755" ]]; then
        ((ok++))
	audit[20,2]="     Yes      "
        audit[20,3]="       /        "
        echo -e "$vert, le dossier /etc/docker est bien restreint en lecture et exécution pour les autres que le propriétaire, qui lui a tous les droits !"
else
        ((bof++))
	audit[20,2]="      /       "
        audit[20,3]="      No        "
        echo -e "$jaune, le dossier /etc/docker n'est pas suffisament restreint, il doit être en 755 !"
fi

#3.15 Ensure that the Docker socket file ownership is set to root:docker
audit[21,0]="$cyan 3.15$blanc\t"
audit[21,1]="$cyan Ensure that the Docker socket file ownership is set to root:docker$blanc\t\t"
dsocket=`stat -c %U:%G /var/run/docker.sock | grep -v root:docker`
if [[ -z "$dsocket" ]]; then
        ((ok++))
	audit[21,2]="     Yes      "
        audit[21,3]="       /        "
        echo -e "$vert, l'utilisateur root et le groupe docker sont bien propriétaires du socket docker !"
else
        ((bof++))
	audit[21,2]="      /       "
        audit[21,3]="      No        "
        echo -e "$jaune, l'utilisateur root et le groupe docker ne sont pas les propritétaires du socket docker !"
fi


#3.16 Ensure that the Docker socket file permissions are set to 660 or more restrictively (Scored)
audit[22,0]="$cyan 3.16$blanc\t"
audit[22,1]="$cyan Ensure that the Docker socket file permissions are set to 660 or more restrictively$blanc"
dperm=`stat -c %a /var/run/docker.sock`
if [[ "$dperm" == "660" ]]; then
        ((ok++))
	audit[22,2]="     Yes     "
        audit[22,3]="       /        "
        echo -e "$vert, le fichier /var/run/docker.sock est bien restreint en lecture et écriture pour le propriétaire et le groupe"
else
        ((bof++))
	audit[22,2]="      /      "
        audit[22,3]="      No        "
        echo -e "$jaune, le fichier /var/run/docker.sock  n'est pas suffisament restreint, il doit être en 660 !"
fi

#3.19 Ensure that the /etc/default/docker file ownership is set to root:root (Scored)
audit[23,0]="$cyan 3.19$blanc\t"
audit[23,1]="$cyan Ensure that the /etc/default/docker file ownership is set to root:root$blanc\t\t"
default=`stat -c %U:%G /etc/default/docker | grep -v root:root`
if [[ -z "$default" ]]; then
        ((ok++))
	audit[23,2]="     Yes      "
        audit[23,3]="       /        "
        echo -e "$vert, root est bien propriétaire du fichier /etc/default/docker !"
else
        ((bof++))
	audit[23,2]="      /       "
        audit[23,3]="      No        "
        echo -e "$jaune, root n'est pas le propritétaire du fichier /etc/default/docker !"
fi

#5.1|5.2 Ensure that, if applicable, an AppArmor Profile is enabled | SELinux options are set (Scored)
audit[24,0]="$cyan 5.1\t\t$blanc"
audit[24,1]="$cyan Ensure that, if applicable, an AppArmor Profile is enabled$blanc\t\t\t"
audit[25,0]="$cyan 5.2$blanc\t\t"
audit[25,1]="$cyan Ensure that, if applicable, SELinux options are set$blanc\t\t\t\t"

armor=`docker ps --quiet --all | xargs docker inspect --format '{{ .Id }}: AppArmorProfile={{ .AppArmorProfile }}'`
selinux=`docker ps --quiet --all | xargs docker inspect --format '{{ .Id }}: SecurityOpt={{ .HostConfig.SecurityOpt }}'`
if [[ "$armor" =~ AppArmorProfile\=\<no\ value\> ]]; then
	if [[ "$selinux" =~ SecurityOpt\=\<no\ value\> ]]; then
        	((bof++))
		audit[24,2]="      /       "
        	audit[24,3]="      No        "
		audit[25,2]="      /       "
                audit[25,3]="      No        "
        	echo -e "$jaune, aucun profil AppArmor n'est activé et aucune option de sécurité n'a été fixée sur SELinux !"
	else
		((ok++))
		audit[24,2]="      /       "
                audit[24,3]="      No        "
		audit[25,2]="     Yes      "
        	audit[25,3]="       /        "
		echo -e "$vert, des options de sécurité ont bien été fixées sur SELinux !"
	fi
else
	if [[ "$selinux" =~ SecurityOpt\=\<no\ value\> ]]; then
		((ok++))
		audit[24,2]="     Yes      "
        	audit[24,3]="       /        "
		audit[25,2]="      /       "
                audit[25,3]="      No        "
	        echo -e "$vert, un profil AppArmor est actuellement actif !"

	else
                ((ok++))
		audit[24,2]="     Yes      "
        	audit[24,3]="       /        "
                audit[25,2]="     Yes      "
                audit[25,3]="       /        "
		echo -e "$vert, des options de sécurité ont bien été fixées sur SELinux et un profil AppArmor et actuellement actif !"
	fi
fi

#5.4 Ensure that privileged containers are not used (Scored)
audit[26,0]="$cyan 5.4$blanc\t\t"
audit[26,1]="$cyan Ensure that privileged ontainers are note used\t$blanc\t\t\t\t"
privi=`docker ps --quiet --all | xargs docker inspect --format '{{ .Id }}: Privileged={{ .HostConfig.Privileged }}'`
if [[ "$privi" =~ Privileged=false ]]; then
        ((ok++))
	audit[26,2]="     Yes      "
        audit[26,3]="       /        "
        echo -e "$vert, aucun conteneur privilégié n'est utilisé !"
else
        ((bof++))
	audit[26,2]="      /       "
        audit[26,3]="      No        "
        echo -e "$jaune, un conteneur est utilisé en mode privilégié !"
fi

#5.9 Ensure that the host's network namespace is not shared (Scored)
audit[27,0]="$cyan 5.9$blanc\t\t"
audit[27,1]="$cyan Ensure that the host's network namespace is not shared$blanc\t\t\t\t"
net=`docker ps --quiet --all | xargs docker inspect --format '{{ .Id }}: NetworkMode={{ .HostConfig.NetworkMode }}'`
if [[ "$net" =~ NetworkMode=host ]]; then
        ((bof++))
	audit[27,2]="      /       "
        audit[27,3]="       No        "
        echo -e "$jaune, le réseau du namespace est fixé sur celui de l'hôte !"
else
        ((ok++))
	audit[27,2]="     Yes      "
        audit[27,3]="       /        "
        echo -e "$vert, le réseau du namespace a été fixé par défaut !"
fi

#5.10 Ensure that the memory usage for containers is limited (Scored)
audit[28,0]="$cyan 5.10$blanc\t"
audit[28,1]="$cyan Ensure that the memory usage for containers is limited$blanc\t\t\t\t"
memory=`docker ps --quiet --all | xargs docker inspect --format '{{ .Id }}: Memory={{ .HostConfig.Memory }}'`
if [[ "$memory" =~ Memory=0 ]]; then
        ((bof++))
	audit[28,2]="      /       "
        audit[28,3]="      No        "
        echo -e "$jaune, aucune limite de mémoire n'a pas été fixé !"
else
        ((ok++))
	audit[28,2]="     Yes      "
        audit[28,3]="       /        "
        echo -e "$vert, une limite d'utilisation de mémoire a bien été fixé !"
fi

#5.11 Ensure that CPU priority is set appropriately on containers (Scored)
audit[29,0]="$cyan 5.11$blanc\t"
audit[29,1]="$cyan Ensure that CPU priority is set appropriately on containers$blanc\t\t\t"
cpu=`docker ps --quiet --all | xargs docker inspect --format '{{ .Id }}: CpuShares={{ .HostConfig.CpuShares }}'`
if [[ "$cpu" =~ CpuShares=(0|1024) ]]; then
        if [ ${BASH_REMATCH[1]} == "0" ] || [ ${BASH_REMATCH[1]} == "1024" ]; then
		((bof++))
		audit[29,2]="      /       "
        	audit[29,3]="      No        "
        	echo -e "$jaune, le partage de CPU n'a pas été correctement mis en place !"
	else
        	((ok++))
		audit[29,2]="     Yes      "
        	audit[29,3]="       /        "
        	echo -e "$vert, le partage de CPU est bien mis en place !"
	fi
else
        ((ok++))
	audit[29,2]="     Yes      "
        audit[29,3]="       /        "
        echo -e "$vert, le partage de CPU est bien mis en place !"
fi

#5.12 Ensure that the container's root filesystem is mounted as read only (Scored)
audit[30,0]="$cyan 5.12$blanc\t"
audit[30,1]="$cyan Ensure that the container's root filesystem is mounted as read only$blanc\t\t"
ro=`docker ps --quiet --all | xargs docker inspect --format '{{ .Id }}: ReadonlyRootfs={{ .HostConfig.ReadonlyRootfs }}'`
if [[ "$ro" =~ ReadonlyRootfs=false ]]; then
        ((bof++))
	audit[30,2]="      /       "
        audit[30,3]="      No        "
        echo -e "$jaune, la racine du filesystem du conteneur n'a pas été monté en lecture seule !"
else
        ((ok++))
	audit[30,2]="     Yes      "
        audit[30,3]="       /        "
        echo -e "$vert, la racine du filesystem du conteneur est bien monté en lecture seule !"
fi

#5.14 Ensure that the on-failure container restart policy is set to 5 (Scored)
audit[31,0]="$cyan 5.14$blanc\t"
audit[31,1]="$cyan Ensure that the on-failure container restart policy is set to 5$blanc\t\t\t"
restartpolicy=`docker ps --quiet --all | xargs docker inspect --format '{{ .Id }}: RestartPolicyName={{ .HostConfig.RestartPolicy.Name }} MaximumRetryCount={{ .HostConfig.RestartPolicy.MaximumRetryCount }}'`
if [[ "$restartpolicy" =~ RestartPolicyName=on-failure ]]; then
	if [[ "$restartpolicy" =~  MaximumRetryCount=5 ]]; then
	        ((ok++))
		audit[31,2]="     Yes      "
        	audit[31,3]="       /        "
        	echo -e "$vert, la policy fixée pour le redémarage du conteneur est optimale !"
	else
		((bof++))
		audit[31,2]="      /       "
        	audit[31,3]="      No        "
		echo -e "$jaune, la policy fixée pour le redémarage du conteneur n'est pas optimale, le nombre maximum de tentatives de redémarrage doit être fixé à 5 !"
	fi
else
        ((bof++))
	audit[31,2]="      /       "
        audit[31,3]="      No        "
        echo -e "$jaune, la policy fixée pour le redémarage du conteneur n'est pas optimale !"
fi

#5.15 Ensure that the host's process namespace is not shared (Scored)
audit[32,0]="$cyan 5.15$blanc\t"
audit[32,1]="$cyan Ensure that the host's process namespace is note shared$blanc\t\t\t\t"
pidm=`docker ps --quiet --all | xargs docker inspect --format '{{ .Id }}: PidMode={{ .HostConfig.PidMode }}'`
if [[ "$pidm" =~ PidMode=host ]]; then
	((bof++))
	audit[32,2]="      /       "
        audit[32,3]="      No        "
        echo -e "$jaune, le processus du namespace de l'hôte est partagé !"
else
        ((ok++))
	audit[32,2]="     Yes      "
        audit[32,3]="       /        "
        echo -e "$vert, le processus du namespace de l'hôte n'est pas partagé !"
fi

#5.16 Ensure that the host's IPC namespace is not shared (Scored)
audit[33,0]="$cyan 5.16$blanc\t"
audit[33,1]="$cyan Ensure that the host's IPC namespace is not shared\t$blanc\t\t\t"
ipc=`docker ps --quiet --all | xargs docker inspect --format '{{ .Id }}: IpcMode={{ .HostConfig.IpcMode }}'`
if [[ "$ipc" =~ IpcMode=host ]]; then
        ((bof++))
	audit[33,2]="      /       "
        audit[33,3]="      No        "
        echo -e "$jaune, l'IPC du namespace de l'hôte est partagé !"
else
        ((ok++))
	audit[33,2]="     Yes      "
        audit[33,3]="       /        "
        echo -e "$vert, l'IPC du namespace de l'hôte n'est pas partagé !"
fi

#5.18 Ensure that the default ulimit is overwritten at runtime if needed (Not Scored)
audit[34,0]="$cyan 5.18$blanc\t"
audit[34,1]="$cyan Ensure that the default ulimit is overwritten at runtime if needed$blanc\t\t"
ulimits=`docker ps --quiet --all | xargs docker inspect --format '{{ .Id }}: Ulimits={{ .HostConfig.Ulimits }}'`
if [[ "$ulimits" =~ Ulimits=\<no\ value\> ]]; then
        ((ok++))
	audit[34,2]="     Yes      "
        audit[34,3]="       /        "
        echo -e "$vert, l'Ulimit est bien défini au niveau du daemon docker !"
else
        ((bof++))
	audit[34,2]="      /       "
        audit[34,3]="      No        "
        echo -e "$jaune, l'Ulimit n'est pas défini au niveau du daemon docker !"
fi

#5.19 Ensure mount propagation mode is not set to shared (Scored)
audit[35,0]="$cyan 5.19$blanc\t"
audit[35,1]="$cyan Ensure mount propagation mode is not set to shared$blanc\t\t\t\t"
prop=`docker ps --quiet --all | xargs docker inspect --format '{{ .Id }}: Propagation={{range $mnt := .Mounts}} {{json $mnt.Propagation}} {{end}}'`
if [[ "$prop" =~ Propagation=shared ]]; then
        ((bof++))
	audit[35,2]="      /       "
        audit[35,3]="      No        "
        echo -e "$jaune, le mode de Propagation est fixé sur le montage des volumes en mode partagé !"
else
        ((ok++))
	audit[35,2]="     Yes      "
        audit[35,3]="       /        "

        echo -e "$vert, le mode Propagation n'est pas fixé sur le montage des volumes en mode partagé  !"
fi

#5.20 Ensure that the host's UTS namespace is not shared (Scored)
audit[36,0]="$cyan 5.20$blanc\t"
audit[36,1]="$cyan Ensure that the host's UTS namespace is not shared$blanc\t\t\t\t"
uts=`docker ps --quiet --all | xargs docker inspect --format '{{ .Id }}: UTSMode={{ .HostConfig.UTSMode }}'`
if [[ "$uts" =~ UTSMode=host ]]; then
        ((bof++))
	audit[36,2]="      /       "
        audit[36,3]="      No        "
        echo -e "$jaune, l'UTS du namespace de l'hôte est partagé !"
else
        ((ok++))
	audit[36,2]="     Yes      "
        audit[36,3]="       /        "
        echo -e "$vert, l'UTS du namespace de l'hôte n'est pas partagé !"
fi

#5.21 Ensure the default seccomp profile is not Disabled (Scored)
audit[37,0]="$cyan 5.21$blanc\t"
audit[37,1]="$cyan Ensure the default seccomp profile is not Disabled$blanc\t\t\t\t"
secuopt=`docker ps --quiet --all | xargs docker inspect --format '{{ .Id }}: SecurityOpt={{ .HostConfig.SecurityOpt }}'`
if [[ "$secuopt" =~ SecurityOpt=\<no\ value\> ]]; then
        ((ok++))
	audit[37,2]="     Yes      "
        audit[37,3]="       /        "
        echo -e "$vert, le profil par défaut de seccomp est bien activé !"
else
        ((bof++))
	audit[37,2]="      /       "
        audit[37,3]="      No        "
        echo -e "$jaune, le profil par défaut de seccomp n'est pas activé !"
fi

#5.24 Ensure that cgroup usage is confirmed (Scored)
audit[38,0]="$cyan 5.24$blanc\t"
audit[38,1]="$cyan Ensure that cgroup usage is confirmed$blanc\t\t\t\t\t\t"
cgroup=`docker ps --quiet --all | xargs docker inspect --format '{{ .Id }}: CgroupParent={{ .HostConfig.CgroupParent }}'`
if [[ "$cgroup" =~ CgroupParent=^ ]]; then
        ((bof++))
	audit[38,2]="      /       "
        audit[38,3]="      No        "
        echo -e "$jaune, l'utilisation d'un cgroup n'est pas confirmé !"
else
        ((ok++))
	audit[38,2]="     Yes      "
        audit[38,3]="       /        "
        echo -e "$vert, l'utilisation d'un cgroup est bien confirmé !"
fi

#5.28 Ensure that the PIDs cgroup limit is used (Scored)
audit[39,0]="$cyan 5.28$blanc\t"
audit[39,1]="$cyan Ensure that the PIDs cgroup limit is used$blanc\t\t\t\t\t\t"
pidlimit=`docker ps --quiet --all | xargs docker inspect --format '{{ .Id }}: PidsLimit={{ .HostConfig.PidsLimit }}'`
if [[ "$pidlimit" =~ PidsLimit=(0|\-1) ]]; then
        ((bof++))
	audit[39,2]="      /       "
        audit[39,3]="      No        "
        echo -e "$jaune, aucune limite sur le PIDs de cgroup n'est utilisée !"
else
        ((ok++))
	audit[39,2]="     Yes      "
        audit[39,3]="       /        "
        echo -e "$vert, une limite sur le PIDs de cgroup est actuellement utilisée !"
fi

#5.29 Ensure that Docker's default bridge docker0 is not used (Not Scored)
audit[40,0]="$cyan 5.29$blanc\t"
audit[40,1]="$cyan Ensure that Docker's default bridge docker0 is not used$blanc\t\t\t\t"
bridge=`docker network ls --quiet | xargs docker network inspect --format '{{ .Name }}: {{ .Options }}'`
if [[ "$bridge" =~ com.docker.network.bridge.name:docker0 ]]; then
        ((bof++))
	audit[40,2]="      /       "
        audit[40,3]="      No        "
        echo -e "$jaune, le bridge de docker par défaut (bridge0) est utilisé !"
else
        ((ok++))
	audit[40,2]="     Yes      "
        audit[40,3]="       /        "
        echo -e "$vert, les conteneurs sont bien sur un réseau définit par l'utilisateur !"
fi

#5.30 Ensure that the host's user namespaces are not shared (Scored)
audit[41,0]="$cyan 5.30$blanc\t"
audit[41,1]="$cyan Ensure that the host's user namespaces are not shared$blanc\t\t\t\t"
usernsmode=`docker ps --quiet --all | xargs docker inspect --format '{{ .Id }}: UsernsMode={{ .HostConfig.UsernsMode }}'`
if [[ "$usernsmode" =~ UsernsMode=^ ]]; then
        ((bof++))
	audit[41,2]="      /       "
        audit[41,3]="      No        "
        echo -e "$jaune, les namespaces utilisateur de l'hôte sont partagés !"
else
        ((ok++))
	audit[41,2]="     Yes      "
        audit[41,3]="       /        "
        echo -e "$vert, les namespaces utilisateur de l'hôte ne sont pas partagés"
fi

#7.1 Ensure swarm mode is not Enabled, if not needed (Scored)
audit[42,0]="$cyan 7.1$blanc\t\t"
audit[42,1]="$cyan Ensure swarm mode is not Enabled, if not needed$blanc\t\t\t\t\t"
swarm=`docker info | grep Swarm`
if [[ "$swarm" =~ Swarm\:\ inactive ]]; then
	((ok++))
	audit[42,2]="     Yes      "
        audit[42,3]="       /        "
	echo -e "$vert, le mode Swarm n'est pas activé"
else
	((bof++))
	audit[42,2]="      /       "
        audit[42,3]="      No        "
	echo -e "$jaune, le mode Swarm est activé"
fi

#Affichage des éléments du tableau
audit[43,0]="$bleu Total$blanc\t"
audit[43,1]="\t\t\t\t\t\t/\t\t\t\t\t"
audit[43,2]="      $ok      "
audit[43,3]="      $bof        "

echo -e "\n__________________________________________________________________________________________________________________________________________________"
for ((i=0;i<=43;i++)) do
	for ((j=0;j<4;j++)) do
		echo -e "|  ${audit[$i,$j]} |\c"
    	done
	echo -e "\n--------------------------------------------------------------------------------------------------------------------------------------------------"
done
