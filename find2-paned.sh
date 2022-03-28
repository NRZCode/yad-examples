#!/bin/bash

find_cmd='@sh -c "run_find \"%1\" \"%2\" \"%3\" \"%4\" \"%5\""'

export fpipe=$(mktemp -u --tmpdir find.XXXXXXXX)
mkfifo "$fpipe"
#exec 3<> "$fpipe"

fkey=$(($RANDOM * $$))

run_find()
{
    echo "6:@disable@"
    if [[ $2 != TRUE ]]; then
        ARGS="-name '$1'"
    else
        ARGS="-regex '$1'"
    fi
    if [[ -n "$4" ]]; then
        d1=$(date +%j --date="${4//.//}")
        d2=$(date +%j)
        d=$(($d1 - $d2))
        ARGS+=" -ctime $d"
    fi
    if [[ -n "$5" ]]; then
        ARGS+=" -exec grep -E '$5' {} \;"
    fi
    ARGS+=" -printf '%p\n%s\n%M\n%TD %TH:%TM\n%u/%g\n'"
    eval find "$3" $ARGS > "$fpipe"
    echo "6:$find_cmd"
}
export -f run_find

yad --plug="$fkey" --tabnum=1 --form --field="Name" '*' --field="Use regex:chk" '' --field="Directory:dir" '' \
    --field="Newer than:dt" '' --field="Content" '' --field="gtk-find:fbtn" "$find_cmd" &

cat "$fpipe" | yad --plug="$fkey" --tabnum=2 --list --dclick-action="xdg-open" \
    --column="Name" --column="Size:num" --column="Perms" --column="Date" --column="Owner" \
    --search-column=1 --expand=column=1 &

yad --paned --key="$fkey" --button="gtk-close:1" --width=700 --height=500 --title="Find files" --window-icon="find"

rm -f "$fpipe"
