#!/bin/bash

Prec=$(expr $3 + 0 2> /dev/null) || Prec=0
case $2 in
    =)  Conta=$(tr 'x,' '*.' <<< "$1")
        echo 1:$(echo "scale=$Prec; $Conta" |
            bc | tr . ,) ;;
    RQ) Conta=$(tr 'x,' '*.' <<< "$1")
        echo 1:$(echo "scale=$Prec; sqrt ($Conta)" |
            bc | tr . ,) ;;
    1X) Conta=$(tr 'x,' '*.' <<< "$1")
        echo 1:$(echo "scale=$Prec; 1/($Conta)" | \
            bc | tr . ,) ;;
    M+) Num=$([ -s ~/.mem ] && cat ~/.mem || echo 0)
        Conta=$(tr , . <<< "$1")
        bc <<< "$Conta + $Num" > ~/.mem ;;
    MR) echo 1:$(cat ~/.mem) ;;
    MC) > ~/.mem ;;
    AP) echo 1:${1%?} ;;
    PR) IFS='|' read lx lx Dec lx <<< \
        "$(yad --form --columns 4 \
            --title "Decimais" \
            --field "\tInforme precisão":LBL '' \
            --field "\tentre 0 e 9 decimais":LBL '' \
            --field '' '' --field :LBL '' \
            --field 1:BTN '@echo 3:1'
            --field 4:BTN '@echo 3:4' \
            --field 7:BTN '@echo 3:7' \
            --field :BTN '' \
            --field 2:BTN '@echo 3:2' \
            --field 5:BTN '@echo 3:5' \
            --field 8:BTN '@echo 3:8' \
            --field 0:BTN '@echo 3:0' \
            --field 3:BTN '@echo 3:3' \
            --field 6:BTN '@echo 3:6' \
            --field 9:BTN '@echo 3:9' \
            --field :BTN '' --button OK)"
        echo 3:$Dec ;;
    +-) Conta=$(tr , . <<< "$1")
        echo 1:$(echo "-1 * $Conta" | bc | tr . ,) ;;
    *)  echo 1:$1
esac
