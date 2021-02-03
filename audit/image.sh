#!/bin/bash

IMAGE=$1

echo -e "\n\n##### ANALYSE DE L'IMAGE ${YELLOW}$IMAGE $WHITE#####\n"
tput sgr0

if [[ $1 == 1 ]]; then
        # on doit chercher toutes les images
        docker images >> temp.txt
        sed -i "s/\s.*//g" temp.txt
        sed -i "1d" temp.txt
else
        # on met le nom de l'image dans un fichier texte
        echo $1 >> temp.txt
fi

### On fait la recherche pour toutes les images
while read image_name
do
        echo -e "\n${PURPLE}RECHERCHE DES PERMISSIONS SUR LE DOCKERFILE\n${WHITE}Recherche de l'image $image_name\n"

tput sgr0

        ### On cherche le docker
        result_search=`docker inspect $image_name`

        lowerdir=`echo $result_search | sed "s/.*LowerDir\": \"//"`
        lowerdir=`echo $lowerdir | sed "s/[:\"].*//"`

        mergeddir=`echo $result_search | sed "s/.*MergedDir\": \"//"`
        mergeddir=`echo $mergeddir | sed "s/[:\"].*//"`

        upperdir=`echo $result_search | sed "s/.*UpperDir\": \"//"`
        upperdir=`echo $upperdir | sed "s/[:\"].*//"`

        workdir=`echo $result_search | sed "s/.*WorkDir\": \"//"`
        workdir=`echo $workdir | sed "s/[:\"].*//"`

        ### Boolean for the display if nothing has to change
        boolean=0

        echo -e "$BLACK"
        ### For each directory, we check if they exist
        if [ -d $lowerdir ]; then
                echo -e "$BLACK"
                ### If they do, we get the owner
                file_meta_lower=($(ls -ld $lowerdir))
                file_owner_lower="${file_meta_lower[2]}"

                ### If the owner is not root, we warn the user
                if [[ $file_owner_lower != "root" ]]; then
                        echo -e "$RED Attention attention !! Le dossier $lowerdir n'a pas l'utilisateur root comme propriétaire"
                        boolean=1
                fi
        fi

                if [ -d $mergeddir ]; then
                        file_meta_merged=($(ls -ld $mergeddir))
                        file_owner_merged="${file_meta_merged[2]}"
                        if [[ $file_owner_merged != "root" ]]; then
                                echo -e "$RED Attention attention !! Le dossier $mergeddir n'a pas l'utilisateur root comme propriétaire"
                                boolean=1
                        fi
                fi

                if [ -d $upperdir ]; then
                        file_meta_upper=($(ls -ld $upperdir))
                        file_owner_upper="${file_meta_upper[2]}"
                        if [[ $file_owner_upper != "root" ]]; then
                                echo -e "$RED Attention attention !! Le dossier $upperdir n'a pas l'utilisateur root comme propriétaire"
                                boolean=1
                        fi
                fi


                if [ -d $workdir ]; then
                        file_meta_work=($(ls -ld $workdir))
                        file_owner_work="${file_meta_work[2]}"
                        #echo "file_owner work: $file_owner_work"

                        if [[ $file_owner_work != "root" ]]; then
                                echo -e "$RED Attention attention !! Le dossier $workdir n'a pas l'utilisateur root comme propriétaire"
                                boolean=1
                        fi
                fi

                ### If root was always the owner, the script displays a message to say all is good
                if [[ $boolean == 0 ]]; then
                        echo -e "$GREEN Félicitations ! Root est bien l'heureux proprietaire des dockerfiles de l'image $image_name\n"
                fi

tput sgr0

done < temp.txt
rm temp.txt

# Utilisateur utilisé par l'image
sortie=$(docker run --rm $IMAGE whoami)
echo -e "${PURPLE}UTILISATEUR UTILISE PAR L'IMAGE : ${sortie}"
tput sgr0
if [[ "$sortie" == "root" ]]
then
        echo -e "${RED}L'utilisateur root doit être modifié. Le principe de moindre privilèges doit être appliqué."
        tput sgr0
fi
sortie=$(docker run --rm $IMAGE id)
echo -e "Droits de l'utilisateur utilisé par l'image : ${sortie}"
echo -e ""

# Tag utilisé
echo -e "${PURPLE}TAG DEFINI :"
tput sgr0
if [[ "$IMAGE" == *":latest" ]]
then
        echo -e "${RED}Le tag latest est à éviter $IMAGE, le tag doit être renseigné"
        tput sgr0
elif [[ "$IMAGE" != *":"* ]]
then
        echo -e "${RED}Le tag doit être renseigné $IMAGE:<tag>"
        tput sgr0
else
        echo -e "${GREEN}Le tag est renseigné"
        tput sgr0
fi
echo -e ""

## Vulnérabilités de l'image
echo -e "${PURPLE}SCAN DES VULNERABILITES :"
tput sgr0
echo -e ""
echo -e "Système d'exploitation :"
trivy image --vuln-type os --severity HIGH,CRITICAL $IMAGE
echo -e ""
echo -e "Librairies :"
trivy image --vuln-type library --severity HIGH,CRITICAL $IMAGE
echo -e "\n\n"


