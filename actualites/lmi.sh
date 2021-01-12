#!/bin/bash

while read line
do
	if [[ $line == *'<h2><a href="https://www.lemondeinformatique.fr/actualites'* ]]; then
		http=`echo $line | sed "s/.*<h2><a href=\"https:\/\/www\.lemondeinformatique\.fr\/actualites/www\.lemondeinformatique\.fr\/actualites/"`
		http=`echo $http | sed "s/\.html.*/\.html/"`
		http=`echo $http | sed "s/\" class \"title\">/ | /"`
                http=`echo $http | sed "s/<\/a><\/h2>.*/ /"`


		echo -e "$http"
	fi
#
done < /home/pfe/actualites/lmi.txt >> /home/pfe/actualites/actualites.txt 
#<h2><a href="https://www.lemondeinformatique.fr/actualites/lire-la-moitie-des-images-de-docker-hub-vulnerables-a-des-failles-critiques-81223.html" class="title">La moitié des images de Docker Hub vulnérables à des failles critiques</a></h2>
