#!/bin/bash

#Tout les tris doivent prendre la même chose en paramètre : test.txt;test2.txt; (peut changer)
#comme ça pour les tris multiple on peut appeler les mêmes fonctions 

#ex: Tri dec prend une chaine sous la forme test.txt;test2.txt; 
#Tri par poid prend une chaine sous la forme test.txt;test2.txt; 
#Donc les 2 sont utilisables séparémment et si jamais les 2 sont demandés (-poid -d) et qu'il y a une égalité on peut appeller l'autre avec les égalités sous la forme fichieravecunpoid.txt;fichieraveclememepoid.txt

function reverseAffiche(){
    #Affiche \$2 chaines de caractere dans \$1 qui est sous la forme test.txt;test.c;test.o; 
    #de la fin au début
    var=$1
    i=$2
    while [ $i -ne 0 ] 
    do
        mot=`echo $var|cut -d';' -f$i`
        echo $mot 
        var="${var%$mot;}"
        i=$[i-1]
    done
}

function Affiche(){
    #Affiche \$2 chaines de caractere dans \$1 qui est sous la forme test.txt;test.c;test.o; 
    #de la fin au début
    var=$1
    i=$2
    while [ $i -ne 0 ] 
    do
        mot=`echo $var|cut -d';' -f$i`
        echo $mot 
        var="${var%$mot;}"
        i=$[i-1]
    done
}

function triS(){
    var=$1
    i=0
    while [ $i -ne $2 ] 
    do
        j=0
        mot=`echo $var|cut -d';' -f$i`
        echo $mot 
        while [ $j -ne $2 ] 
        do
            mot=`echo $var|cut -d';' -f$i`
            echo $mot 
            var="${var%$mot;}"
        done
        i=$[i+1]
    done
}
function ls(){
    #Affiche le répertoire \$1 sans le chemin donné en paramètre
    for i in "$1"/*
    do
        tmp="${i#$1/}"
        echo $tmp
    done
}

function savels(){
    #Sauvegarde le repertoire \$1 sous la forme test.txt;test.c;
    save=""
    cpt=0
    for i in "$1"/*
    do
        tmp="${i#$1/}"
        if [ $cpt -eq 0 ]
        then
            save="$tmp;"
        else
            save="$save$tmp;"
        fi
        cpt=$[cpt+1]
    done
    echo "$save $cpt"
}

function triDec(){
    res=$(savels $1)
    nb=`echo $res|cut -d' ' -f2`
    liste="${res%$nb}"
    reverseAffiche $liste $nb
}

function lsR(){
    for i in "$1"/*
    do
        tmp="${i#$1/}"
        for((j=0;j<$2-1;j++))
        do
            echo -n "|      "
        done
        if [ $2 -ne 0 ] 
        then
            echo -n "|--" 
        fi
        if [ -d $i ] 
        then
            if [ $2 -ne 0 ] 
            then
                echo -n ")" 
            fi
            echo "$tmp"
            var=$(($2+1))
            lsR $i $var
        else
            if [ $2 -ne 0 ] 
            then
                echo -n ">" 
            fi
            echo "$tmp"
        fi
    done
}

[ $# -lt 1 ] && echo "Veuillez rentrer au moins 1 argument !" && echo "$0 [-R] [-d] [-nsmletpg] rep" &&exit 1
[ $# -gt 4 ] && echo "Il ne peut y avloir plus de 4 arguments !" && echo "$0 [-R] [-d] [-nsmletpg] rep" && exit 1

recursive=0
decroissant=0
if [ $1 == "-R" ] 
then
    echo "recursive 1"
    recursive=1
    shift
fi
if [ $1 == "-d" ] 
then
    echo "décroissant 1"
    decroissant=1
    shift
fi
#rajouter autres parametres
if [ $decroissant -eq 1 -a $recursive -eq 1 ]
then
    echo "Les 2"
    triDec $1
elif [ $decroissant -eq 1 ] 
then
    echo "tri decroissant"
    triDec $1
elif [ $recursive -eq 1 ] 
then
    echo "Recursive"
    lsR $1 0
else
    echo "ls normal"
    ls $1
fi