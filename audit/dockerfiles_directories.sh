#!/bin/bash



######################################################################################################################
######################################################################################################################
################										      ################	
################	   Recherche des permissions des fichiers des images des dockers	      ################
################										      ################
######################################################################################################################
######################################################################################################################

### $1 == 1 => audit de tous les conteneurs
### $1 == 2 => audit d'un seul conteneur



#read -p "Nom du docker : " docker_name
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
	echo -e "\n${BLUE}Recherche des permissions des fichiers des images des images docker\nRecherche de l'image $image_name\n"

tput sgr0

	### On cherche le docker
	result_search=`docker inspect $image_name`
	#echo -e "\nDocker info : \n\n.$result_search."


	lowerdir=`echo $result_search | sed "s/.*LowerDir\": \"//"`
	lowerdir=`echo $lowerdir | sed "s/[:\"].*//"`

	mergeddir=`echo $result_search | sed "s/.*MergedDir\": \"//"`
	mergeddir=`echo $mergeddir | sed "s/[:\"].*//"`

	upperdir=`echo $result_search | sed "s/.*UpperDir\": \"//"`
	upperdir=`echo $upperdir | sed "s/[:\"].*//"`

	workdir=`echo $result_search | sed "s/.*WorkDir\": \"//"`
        workdir=`echo $workdir | sed "s/[:\"].*//"`


#	echo -e "\nLowerDir : $lowerdir"
#	echo -e "\nMergedDir : $mergeddir"
#	echo -e "\nUpperDir : $upperdir"
#	echo -e "\nWorkDir : $workdir"

	### Boolean for the display if nothing has to change
	boolean=0

	echo -e "$BLACK"
	### For each directory, we check if they exist
	if [ -d $lowerdir ]; then
		echo -e "$BLACK"
		### If they do, we get the owner
		file_meta_lower=($(ls -ld $lowerdir))
		file_owner_lower="${file_meta_lower[2]}"
		#echo "file_owner lower: $file_owner_lower"

		### If the owner is not root, we warn the user
		if [[ $file_owner_lower != "root" ]]; then
                	echo -e "\n$RED Attention attention !! Le dossier $lowerdir n'a pas l'utilisateur root comme propriétaire"
			boolean=1
       		fi
	fi

		if [ -d $mergeddir ]; then
			file_meta_merged=($(ls -ld $mergeddir))
        		file_owner_merged="${file_meta_merged[2]}"
		        #echo "file_owner merged:__ $file_owner_merged"

			if [[ $file_owner_merged != "root" ]]; then
                		echo -e "\n$RED Attention attention !! Le dossier $mergeddir n'a pas l'utilisateur root comme propriétaire"
				boolean=1
		        fi
		fi

		if [ -d $upperdir ]; then
			file_meta_upper=($(ls -ld $upperdir))
	        	file_owner_upper="${file_meta_upper[2]}"
        		#echo "file_owner upper: $file_owner_upper"

			if [[ $file_owner_upper != "root" ]]; then
	                	echo -e "\n$RED Attention attention !! Le dossier $upperdir n'a pas l'utilisateur root comme propriétaire"
				boolean=1
        		fi
		fi


		if [ -d $workdir ]; then
			file_meta_work=($(ls -ld $workdir))
        		file_owner_work="${file_meta_work[2]}"
		        #echo "file_owner work: $file_owner_work"
		
			if [[ $file_owner_work != "root" ]]; then
	                	echo -e "\n$RED Attention attention !! Le dossier $workdir n'a pas l'utilisateur root comme propriétaire"
				boolean=1
        		fi
		fi

		### If root was always the owner, the script displays a message to say all is good
		if [[ $boolean == 0 ]]; then
			echo -e "\n\n$GREEN Félicitations ! Root est bien l'heureux proprietaire des dockerfiles de l'image $image_name\n"
		fi
#	fi

tput sgr0

done < temp.txt
echo -e "\n\n${BLUE}Fin recommendation dockerfiles\n"
rm temp.txt

tput sgr0

exit 2
