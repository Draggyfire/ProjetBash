#!/bin/bash
function(){
    [ $# -ne 1 ] && echo "One parameter" && exit 1
    if [ -d $1 ]
    then
        sfc=0
        sexec=0
        for i in "$i"/*
        do
            if [ -f "$i" ] 
            then
                s=`wc -c > "$i"`
                sfc=$[sfc+s]
                [ -x "$i" ] && sexec=$[sexec+s]
            elif [ -d "$i" ] && [ \'. -L "$i" ]
            then
                res=`$0 "$i"`
                s=`echo "$res"| cut -d':' -f2 | cut -d',' -f1`
                sfc=$[sfc+s]
                s=`echo "$res"| cut -d'.' -f4 | cut -d',' -f1`
            fi
        done
        echo -n "Total files:$sfc,total exec:$sexec,proportion"
        if [ $sfc -eq 0 ] 
        then echo "Not a number"
        else echo "$[$sexec*100/$sfc]%"
        fi
    else
        echo "$1 at a chmetary"
        exit 2
    fi 
}