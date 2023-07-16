# NVEH-modelling

## Auteures
LÉGLISE Cloé (<a href="https://github.com/SalsyUniate">GitHub</a>)<br>
SAINT-MARTIN Camille (<a href="https://github.com/csaintmartin">GitHub</a>)
<br><br>

## Objectif du projet
Cette application a été réalisée dans le cadre d'un projet de recherche sur la récupération d'énergie vibratoire. Son but est de permettre la visualisation du comportement de différents oscillateurs mécaniques et récupérateurs d'énergie par l'utilisateur afin de mieux les comprendre. 
<br><br>


## Installation
Pour faire fonctionner cette application, il est nécessaire d'utiliser une machine ayant le langage (<a href="https://julialang.org/downloads/">Julia</a>) d'installé. L'installation de l'environnement du projet peut prendre un certain temps. <br>

En se plaçant à la racine du projet, il faut activer l'environnement du projet avec la commandes : 

```
julia --project="."
```
Puis, dans la console permettant de gérer les packages (qui apparaît avec la commande "]") : 

```
instantiate
```
suivi de :
```
precompile
```

Ces deux dernière étapes peuvent prendre un certain temps, mais ne sont à effectuer qu'une fois, au premier lancement de l'application, ou en cas de modification de l'environnement.
<br><br>

## Exécution
Pour lancer le projet, après avoir en avoir activé l'environnement, il faut exécuter la commande : 
```
include("src.main.jl")
```
Au premier lancement, cela peut prendre un certain temps, ainsi que le lancement des différentes animations.
<br><br>

## Remerciements 
Nous tenons à remercier Ludovic CHARLEUX (<a href="https://github.com/lcharleux">GitHub</a>) pour son aide et sa participation.<br><br>

## Licence
Ce code est libre de droits.
