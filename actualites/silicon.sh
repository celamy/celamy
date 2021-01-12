#!/bin/bash

while read line
do
	if [[ $line == *'a rel="follow" href="https://www.silicon.fr/'* ]]; then
		http=`echo $line | sed "s/.*a rel\=\"follow\" href=\"https:\/\/www\.silicon\.fr/www\.silicon.fr/"`
		http=`echo $http | sed "s/\.html/\.html/"`
		http=`echo $http | sed "s/\" title=\"/ | /"`
		http=`echo $http | sed "s/\">.*//"`
		# On affiche le lien
		echo -e "$http"
	fi
done < /home/pfe/actualites/silicon.txt > /home/pfe/actualites/actualites.txt
#<a rel="follow" href="https://www.silicon.fr/aws-firelens-amazon-ecs-fargate-326535.html" title="Cloud : AWS lance FireLens pour Amazon ECS et Fargate">
