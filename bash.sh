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
    i=$2
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
    i=1
    while [ $i -le $2 ]; do
        mot=$(echo $var | cut -d';' -f$i)
        echo $mot
        var="${var%$mot;}"
        i=$((i + 1))
    done
}

function triS() {
    var=$1
    i=0
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

save=""
cpt=0

function savelsR() {
    #Sauvegarde recursievement le repertoire $1 sous la forme test.txt;test.c;
    for i in "$1"/*; do
        tmp="${i#$1/}"
        save="$save$tmp;"
        cpt=$((cpt + 1))
        if [ -d $i ]; then
            savelsR $i
        fi
    done
}

function triDec() {
    res=$(savels $1)
    nb=$(echo $res | cut -d' ' -f2)
    liste="${res%$nb}"
    reverseAffiche $liste $nb
}

function getWord() {
    #echo le mot à l'index $2 de la chaine $1
    var=$(echo "$1" | cut -d';' -f$(($2 + 1)))
    echo $var
}

function lenStr() {
    #calcule le nb de mots dans une chaine de carac sous la forme zzaiecj.txt;zaeijczia;zaiej;
    tailleTotal=$(echo -n $1 | wc -c)
    nbLettres=$(echo -n $1 | sed 's/;//g' | wc -c)
    nbMots=$((tailleTotal - nbLettres))
    echo "$nbMots"
}

liste_gauche=""
liste_droite=""
liste=""
testList=""

function putListe() {
    # $1 mot $2 index
    #echo "--------------------"
    #echo "PutListe : $1 $2"
    local len_liste=$(lenStr $liste)
    local avListe=""
    local apListe=""
    if [ $2 -ge $len_liste ]; then
        if [ -z $liste ]; then
            liste="$1;"
        else
            liste="$liste$1;"
        fi
    else
        if [ $2 -gt 0 ]; then
            avListe=$(echo "$liste" | cut -d';' -f-$(($2)))
        fi
        apListe=$(echo "$liste" | cut -d';' -f$(($2 + 2))-)

        if [ -z $apListe ]; then
            if [ -z $avListe ]; then
                liste="$1;"
            else
                liste="$avListe;$1;"
            fi
        else
            if [ -z $avListe ]; then
                liste="$1;$apListe"
            else
                liste="$avListe;$1;$apListe"
            fi
        fi
    fi
    #echo "--------------------"
}

function cmp() {
    #ajoute le mot gauche OU droite a l'aide de la fonction putListe en fonction de paramTri
    #$1: motGauche
    #$2: motDroite
    #$3: indiceListe
    #$4: paramTri
    [ $# -ne 4 ] && "4 parametres dans la fonction cmp" && exit 1

    paramTriCpt=0
    added=0
    while [ $added -eq 0 -a $paramTriCpt -le ${#4} ]; do
        myParam=${4:paramTriCpt:1}
        case $myParam in
        n)
            if [ "$mot_gauche" \< "$mot_droite" ]; then
                putListe $mot_gauche $indice_liste
                indice_gauche=$((indice_gauche + 1))
                added=1
            else #changer en elif et dans le else changer myParam, ajouter 1 à paramTriCpt et laisser added à 0
                putListe $mot_droite $indice_liste
                indice_droite=$((indice_droite + 1))
                added=1
            fi
            ;;
        *)
            echo "unknown"
            ;;
        esac

        paramTriCpt=$((paramTriCpt + 1))
    done
}

function fusion() {
    #Prend chaine de caracteres à trier en param
    n=$(lenStr $1)
    if [ $n -gt 1 ]; then
        local milieu=$((n / 2))
        local liste_gauche=$(echo "$1" | cut -d';' -f-$milieu)
        liste_gauche="$liste_gauche;"
        local liste_droite=$(echo "$1" | cut -d';' -f$((milieu + 1))-)
        testList=""
        liste=""
        fusion $liste_gauche $2
        liste_gauche=$testList
        testList=""
        fusion $liste_droite $2
        liste_droite=$testList
        #echo "Liste param : $1"

        local indice_liste=0
        local indice_gauche=0
        local indice_droite=0
        local len_gauche=$(lenStr $liste_gauche)
        local len_droite=$(lenStr $liste_droite)
        local mot_gauche=""
        local mot_droite=""

        while [ $indice_gauche -lt $len_gauche -a $indice_droite -lt $len_droite ]; do
            #echo "LG : $liste_gauche iG :  $indice_gauche"
            #echo "LD : $liste_droite iD :  $indice_droite"
            mot_gauche=$(getWord $liste_gauche $indice_gauche)
            mot_droite=$(getWord $liste_droite $indice_droite)
            #echo "MotG : $mot_gauche  | MotD : $mot_droite"
            cmp $mot_gauche $mot_droite $indice_liste "$2"
            indice_liste=$((indice_liste + 1))
        done

        while [ $indice_gauche -lt $len_gauche ]; do
            mot_gauche=$(getWord $liste_gauche $indice_gauche)
            putListe $mot_gauche $indice_liste
            indice_gauche=$((indice_gauche + 1))
            indice_liste=$((indice_liste + 1))
        done
        while [ $indice_droite -lt $len_droite ]; do
            mot_droite=$(getWord $liste_droite $indice_droite)
            putListe $mot_droite $indice_liste
            indice_droite=$((indice_droite + 1))
            indice_liste=$((indice_liste + 1))
        done
        testList=$liste
    else
        testList=$1
    fi
}

function trifusion() {
    # prend chaine de carac en $1
    fusion $1 "$2"
    #echo "Liste : $liste"
}

#trifusion "A;Z;E;R;T;Y;U;I;O;P;Q;S;D;F;G;H;J;K;L;M;W;X;C;V;B;N;"

[ $# -eq 0 -o $# -gt 4 ] && "Veuillez rentrer entre 1 et 4 parametres !" && exit 1

decroissant=0
recursive=0
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

#verifie l'ordre des tri a effectuer (ne prend en compte que les tri ayant pour valeur $availableTriParam)
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

if [ $recursive -eq 1 ]; then
    savelsR $1
    nb=$cpt
    liste=$save
else
    res=$(savels $1)
    echo "res: $res"
    nb=$(echo $res | cut -d' ' -f2)
    liste="${res%$nb}"
fi

if [ -n $triParam ]; then
    #echo "Liste: $liste"
    echo "triParam: $triParam"
    trifusion $liste "$triParam"
fi

if [ $decroissant -eq 1 ]; then
    echo "tri decroissant:"
    reverseAffiche $liste $nb
else
    echo "Affiche:"
    Affiche $liste $nb
fi
