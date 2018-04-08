# Picture In Picture

Ce projet consiste en la réalisation, d'abord, de trois implémentations des réseaux de Kahn, et ensuite, d'un système de Picture-in-Picture (PiP) utilisant l'implémentation de ces réseaux. Ce projet a été réalisé par Joseph Marotte et [Lucas Willems](http://www.lucaswillems.com) pour le cours de [Systèmes et réseaux](http://www.di.ens.fr/~pouzet/cours/systeme/) donné par Marc Pouzet et Timothy Bourke pour la L3 d'informatique de l'ENS Ulm.

## Structure du projet

Le projet (dans le dossier `src`) contient un `Makefile` permettant d'exécuter les 2 commandes :
- `make pip` : pour compiler notre Picture-in-Picture
- `make example` : pour compiler l'exemple du sujet utilisant les réseaux de Kahn

4 dossiers :
- `data` contenant les vidéos qui seront utilisées pour le Picture-in-Picture
- `image` contenant un petit module pour manipuler les images (au format PPM ici)
- `kahn` contenant un petit module pour utiliser les réseaux de Kahn
- `video` contenant un petit module pour manipuler les vidéos

Et 2 fichiers :
- `example.ml` contenant l'exemple du sujet
- `pip.ml` contenant notre implémentation du Picture-in-Picture

## Picture-in-Picture

Pour utiliser notre Picture-in-Picture, il vous faut exécuter le fichier `pip.native` et utiliser les touches `a`, `b`, `c`... pour sélectionner la chaîne principale et la chaîne secondaire (si envie).