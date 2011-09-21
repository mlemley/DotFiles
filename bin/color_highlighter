#!/bin/bash
# tputcolors

TPUT=$(which tput)
if [[ -n $TPUT && -x $TPUT ]] ; then
        R=`tput setaf 1; tput bold`
        G=`tput setaf 2;`
        Y=`tput setaf 3;`
        X=`tput sgr0`
        P=`tput setaf 5;`
        B=`tput setaf 6;`
        BB=`tput setaf 6; tput bold`
else
        R=`echo -en "\\033[1;31m"`
        G=`echo -en "\\033[1;32m"`
        Y=`echo -en "\\033[1;33m"`
        X=`echo -en "\\033[0;39m"`
        P=`echo -en "\\033[0;35m"`
        B=`echo -en "\\033[0;34m"`
        BB=`echo -en "\\033[1;36m"`
fi

while read line ; do
    case "$line" in
        *Running*)
            echo -n "${G}"
            ;;
        *Test*)
            echo -n "${BB}"
            ;;
        *[Ee]rror*|*problem*|*ERROR*|*E/*|*[Ff]ailure*)
            echo -n "${R}"
            ;;
        *[Ww]arning*|*WARNING*|*W/*|*mkdir*|*delete*|*copy*)
            echo -n "${Y}"
            ;;
        *SUCCESS*|*SUCCESSFUL*|*D/*|*aapt*|*apkbuilder*|*Success*|*javac*)
            echo -n "${G}"
            ;;
        *time*|*setup*|*bytes*|*[Mm]emory*|*Finished*|*--[-+$]*|*System.out*)
            echo -n "${B}"
            ;;
        *INFO*|*I/*|*echo*|*apply*|*exec*)
            echo -n "${P}"
            ;;
        esac
        echo -e "$line${X}"
done
