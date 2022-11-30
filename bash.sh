#!/bin/bash

#Tout les tris doivent prendre la même chose en paramètre : test.txt;test2.txt; (peut changer)
#comme ça pour les tris multiple on peut appeler les mêmes fonctions

#ex: Tri dec prend une chaine sous la forme test.txt;test2.txt;
#Tri par poid prend une chaine sous la forme test.txt;test2.txt;
#Donc les 2 sont utilisables séparémment et si jamais les 2 sont demandés (-poid -d) et qu'il y a une égalité on peut appeller l'autre avec les égalités
#sous la forme fichieravecunpoid.txt;fichieraveclememepoid.txt

availableTriParam=nsmletpg

function triIsAvailable() {
    #check si la lettre correspondant au tri est possible
    [ $# -ne 1 ] && echo "veuillez rentrez 1 parametre dans la fonction triIsAvailable !" && exit 1
    local i
    for ((i = 0; i < ${#availableTriParam}; i++)); do
        [ ${availableTriParam:i:1} == "$1" ] && return 0
    done
    return 1
}

function takeOffWord() {
    #retire le mot numero $1 dans la chaine $chaineTri
    [ $# -ne 1 ] && echo "Veuillez rentrer 1 parametre dans le fonction takeOffWord !" && exit 1
    takeOffWordString=""
    for ((i = 1; i <= $end; i++)); do
        if [ $i -ne $1 ]; then
            takeOffWordTmp=$(echo "$chaineTri" | cut -d';' -f$i)
            takeOffWordString="$takeOffWordString;$takeOffWordTmp"
        fi
    done
    chaineTri=$takeOffWordString
    chaineTri=${chaineTri:1}
    end=$(($end - 1))
}

function reverseAffiche() {
    #Affiche $2 chaines de caractere dans $1 qui est sous la forme test.txt;test.c;test.o;
    #de la fin au début
    var=$1
    local i=$2
    while [ $i -ne 0 ]; do
        mot=$(echo $var | cut -d';' -f$i)
        echo $mot
        var="${var%$mot;}"
        i=$((i - 1))
    done
}

function Affiche() {
    #Affiche $2 chaines de caractere dans $1 qui est sous la forme test.txt;test.c;test.o;
    #de la fin au début
    var=$1
    local i=$2
    while [ $i -ne 0 ]; do
        mot=$(echo $var | cut -d';' -f$i)
        echo $mot
        var="${var%$mot;}"
        i=$((i - 1))
    done
}

function triS() {
    var=$1
    local i=0
    while [ $i -ne $2 ]; do
        j=0
        mot=$(echo $var | cut -d';' -f$i)
        echo $mot
        while [ $j -ne $2 ]; do
            mot=$(echo $var | cut -d';' -f$i)
            echo $mot
            var="${var%$mot;}"
        done
        i=$((i + 1))
    done
}
function ls() {
    #Affiche le répertoire $1 sans le chemin donné en paramètre
    for i in "$1"/*; do
        tmp="${i#$1/}"
        echo $tmp
    done
}

function savels() {
    #Sauvegarde le repertoire $1 sous la forme test.txt;test.c;
    save=""
    cpt=0
    for i in "$1"/*; do
        tmp="${i#$1/}"
        if [ $cpt -eq 0 ]; then
            save="$tmp;"
        else
            save="$save$tmp;"
        fi
        cpt=$((cpt + 1))
    done
    echo "$save $cpt"
}

function triDec() {
    res=$(savels $1)
    nb=$(echo $res | cut -d' ' -f2)
    liste="${res%$nb}"
    reverseAffiche $liste $nb
}

function lsR() {
    for i in "$1"/*; do
        tmp="${i#$1/}"
        for ((j = 0; j < $2 - 1; j++)); do
            echo -n "|      "
        done
        if [ $2 -ne 0 ]; then
            echo -n "|--"
        fi
        if [ -d $i ]; then
            if [ $2 -ne 0 ]; then
                echo -n ")"
            fi
            echo "$tmp"
            var=$(($2 + 1))
            lsR $i $var
        else
            if [ $2 -ne 0 ]; then
                echo -n ">"
            fi
            echo "$tmp"
        fi
    done
}

#TODO
function triFusion() {
    #lance le tri fusion sur $1
    #la variable chaineTri contient la chaine qui sera tri dans les fonctions correspondantes
    #$1: le nombre d'élement
    #$2 (optionelle): l'ordre dans lequel les tri sont effectue
    [ $# -lt 1 -o $# -gt 2 ] && echo "Veuillez rentrer 1 ou 2 parametres dans la fonction triFusion" && exit 1
    [ $1 -le 1 ] && return 0
    middle=$(($1 / 2))
    end=$1
    if [ $# -eq 2 ]; then
        #TODO
        echo "pas encore fait triFusion"
    else
        chaineEnTri=""
        triN 1 $middle " "
        triN $middle $end " "
        chaineTri=$chaineEnTri
    fi
}

function triN() {
    #$1: debut premier tableau
    #$2: debut 2eme tableau
    #$3: ordre tri (peut valoir " ")
    [ $# -ne 3 ] && echo "3 arguments dans la fonction triN" && exit 1
    local tabA=$(echo "$chaineTri" | cut -d';' -f$1)
    local tabB=$(echo "$chaineTri" | cut -d';' -f$2)
    echo "chaineTri: $chaineTri"
    echo "chaineEnTri: $chaineEnTri"
    echo "tabA: $tabA"
    echo "tabB: $tabB"
    echo "------------------------"
    if [ -z $tabA ]; then
        chaineEnTri="$chaineEnTri;$tabB"
        return 0
    elif [ -z $tabB ]; then
        chaineEnTri="$chaineEnTri;$tabA"
        return 0
    fi
    if [ "$tabA" \< "$tabB" ]; then
        takeOffWord $1
        chaineEnTri="$chaineEnTri;$tabA"
        triN $1 $(($2 - 1)) "$3"
        return 0
    elif [ "$tabA" \> "$tabB" ]; then
        takeOffWord $2
        chaineEnTri="$chaineEnTri;$tabB"
        triN $1 $2 "$3"
        return 0
    else
        case "$4" in
        *)
            takeOffWord $1
            chaineEnTri="$chaineEnTri;$tabA"
            triN $1 $(($2 - 1)) "$3"
            return 0
            ;;
        esac

    fi
}

[ $# -lt 1 ] && echo "Veuillez rentrer au moins 1 argument !" && echo "$0 [-R] [-d] [-nsmletpg] rep" && exit 1
[ $# -gt 4 ] && echo "Il ne peut y avoir plus de 4 arguments !" && echo "$0 [-R] [-d] [-nsmletpg] rep" && exit 1

recursive=0
decroissant=0
triParam=""
chaineTri=""

if [ "$1" == "-R" ]; then
    echo "recursive 1"
    recursive=1
    shift
fi
if [ "$1" == "-d" ]; then
    echo "décroissant 1"
    decroissant=1
    shift
fi

#verifie l'ordre des tri a effectuer ( ne prend en compte que les tri ayant pour valeur $availableTriParam)
if [ "${1:0:1}" == "-" ]; then
    ThirdParamCpt=1
    while [ $ThirdParamCpt -lt ${#1} ]; do
        triChar=${1:ThirdParamCpt:1}
        triIsAvailable $triChar
        [ $? -eq 0 ] && triParam=$triParam$triChar
        ThirdParamCpt=$((ThirdParamCpt + 1))
    done
    shift
    #echo "tri: $triParam"
fi

if [ $triParam != "" ]; then
    res=$(savels $1)
    nb=$(echo $res | cut -d' ' -f2)
    chaineTri="${res%$nb}"
    echo "chaine1: $chaineTri"
    triFusion $nb
    echo "chaine2: $chaineTri"
fi

if [ $decroissant -eq 1 -a $recursive -eq 1 ]; then
    echo "Les 2"
    triDec $1
elif [ $decroissant -eq 1 ]; then
    echo "tri decroissant"
    triDec $1
elif [ $recursive -eq 1 ]; then
    echo "Recursive"
    lsR $1 0
else
    echo "ls normal"
    ls $1
fi
