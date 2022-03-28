#! /bin/bash
# -*- mode: sh -*-


KEY=$RANDOM

res1=$(mktemp --tmpdir term-tab1.XXXXXXXX)
res2=$(mktemp --tmpdir term-tab2.XXXXXXXX)
res3=$(mktemp --tmpdir term-tab3.XXXXXXXX)

out=$(mktemp --tmpdir term-out.XXXXXXXX)

# cleanup
trap "rm -f $res1 $res2 $res3 $out" EXIT

export YAD_OPTIONS="--bool-fmt=t --separator='\n' --quoted-output"

rc_file="${1:-$HOME/.Xresources}"

# parse rc file
while read ln; do
    case $ln in
        *allow_bold:*) bold=$(echo ${ln#*:}) ;;
        *font:*) font=$(echo ${ln#*:}) ;;
        *scrollBar:*) sb=$(echo ${ln#*:}) ;;
        *loginShell:*) ls=$(echo ${ln#*:}) ;;
        *title:*) title=$(echo ${ln#*:}) ;;
        *termName:*) term=$(echo ${ln#*:}) ;;
        *geometry:*) geom=$(echo ${ln#*:}) ;;
        *foreground:*) fg=$(echo ${ln#*:}) ;;
        *background:*) bg=$(echo ${ln#*:}) ;;
        *highlightColor:*) hl=$(echo ${ln#*:}) ;;
        *highlightTextColor:*) hlt=$(echo ${ln#*:}) ;;
        *color0:*) cl0=$(echo ${ln#*:}) ;;
        *color1:*) cl1=$(echo ${ln#*:}) ;;
        *color2:*) cl2=$(echo ${ln#*:}) ;;
        *color3:*) cl3=$(echo ${ln#*:}) ;;
        *color4:*) cl4=$(echo ${ln#*:}) ;;
        *color5:*) cl5=$(echo ${ln#*:}) ;;
        *color6:*) cl6=$(echo ${ln#*:}) ;;
        *color7:*) cl7=$(echo ${ln#*:}) ;;
        *color8:*) cl8=$(echo ${ln#*:}) ;;
        *color9:*) cl9=$(echo ${ln#*:}) ;;
        *color10:*) cl10=$(echo ${ln#*:}) ;;
        *color11:*) cl11=$(echo ${ln#*:}) ;;
        *color12:*) cl12=$(echo ${ln#*:}) ;;
        *color13:*) cl13=$(echo ${ln#*:}) ;;
        *color14:*) cl14=$(echo ${ln#*:}) ;;
        *color15:*) cl15=$(echo ${ln#*:}) ;;
        !*) ;; # skip comments
        "") ;; # skip empty lines
        *) misc+=$(echo "$ln\n") ;;
    esac
done < <(xrdb -query | grep -i rxvt)

width=${geom%%x*}
height=${geom##*x}
fn=$(pfd -p -- "$font")

echo $font
echo $fn

# main page
yad --plug=$KEY --tabnum=1 --form \
    --field=$"Title:" "${title:-Terminal}" \
    --field=$"Width::num" ${width:-80} \
    --field=$"Height::num" ${height:-25} \
    --field=$"Font::fn" "${fn:-Monospace}" \
    --field=$"Term:" "${term:-rxvt-256color}" \
    --field=$"Enable login shell:chk" ${ls:-false} \
    --field=$"Enable scrollbars:chk" ${sb:-false} \
    --field=$"Use bold font:chk" ${bold:-false} \
    --field=":lbl" "" \
    --field=$"Foreground::clr" ${fg:-#ffffff} \
    --field=$"Background::clr" ${bg:-#000000} \
    --field=$"Highlight::clr" ${hl:-#0000f0} \
    --field=$"Highlight text::clr" ${hlt:-#ffffff} > $res1 &

# palette page
yad --plug=$KEY --tabnum=2 --form --columns=2 \
    --field=$"Black::clr" ${cl0:-#2e3436} \
    --field=$"Red::clr" ${cl1:-#cc0000} \
    --field=$"Green::clr" ${cl2:-#4e9a06} \
    --field=$"Brown::clr" ${cl3:-#c4a000} \
    --field=$"Blue::clr" ${cl4:-#3465a4} \
    --field=$"Magenta::clr" ${cl5:-#75507b} \
    --field=$"Cyan::clr" ${cl6:-#06989a} \
    --field=$"Light gray::clr" ${cl7:-#d3d7cf} \
    --field=$"Gray::clr" ${cl8:-#555753} \
    --field=$"Light red::clr" ${cl9:-#ef2929} \
    --field=$"Light green::clr" ${cl10:-#8ae234} \
    --field=$"Yellow::clr" ${cl11:-#fce94f} \
    --field=$"Light blue::clr" ${cl12:-#729fcf} \
    --field=$"Light magenta::clr" ${cl13:-#ad7fa8} \
    --field=$"Light cyan::clr" ${cl14:-#34e2e2} \
    --field=$"White::clr" ${cl15:-#eeeeec} > $res2 &

# misc page
echo -e $misc | yad --plug=$KEY --tabnum=3 --text-info --editable > $res3 &

# main dialog
yad --window-icon=utilities-terminal \
    --notebook --key=$KEY --tab=$"Main" --tab=$"Palette" --tab=$"Misc" \
    --title=$"Terminal settings" --image=utilities-terminal \
    --width=400 --image-on-top --text=$"Terminal settings (URxvt)"

# recreate rc file
if [[ $? -eq 0 ]]; then
    mkdir -p ${rc_file%/*}

    eval TAB1=($(< $res1))
    eval TAB2=($(< $res2))

    echo -e "! urxvt settings\n" > $out

    # add main
    cat <<EOF >> $out
URxvt.title: ${TAB1[0]}
URxvt.geometry: ${TAB1[1]}x${TAB1[2]}
URxvt.font: $(pfd "${TAB1[3]}")
URxvt.termName: ${TAB1[4]}
URxvt.loginShell: ${TAB1[5]}
URxvt.scrollBar: ${TAB1[6]}
URxvt.allow_bold: ${TAB1[7]}

URxvt.foreground: ${TAB1[9]}
URxvt.background: ${TAB1[10]}
URxvt.highlightColor: ${TAB1[11]}
URxvt.highlightTextColor: ${TAB1[12]}
EOF
    # add palette
    echo >> $out
    for i in {0..15}; do
        echo "URxvt.color$i: ${TAB2[$i]}" >> $out
    done
    echo >> $out

    # add misc
    cat $res3 >> $out
    echo >> $out

    # load new settings
    #xrdb -merge $out

    if [[ $rc_file == $HOME/.Xresources ]]; then
        [[ -e $rc_file ]] && sed -i "/^URxvt.*/d" $rc_file
        cat $out >> $rc_file
    else
        mv -f $out $rc_file
    fi
fi
