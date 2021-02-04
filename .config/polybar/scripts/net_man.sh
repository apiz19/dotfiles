#!/bin/sh

update() {
    sum=0
    for arg; do
        read -r i < "$arg"
        sum=$(( sum + i ))
    done
    cache=${XDG_CACHE_HOME:-$HOME/.cache}/${1##*/}
    [ -f "$cache" ] && read -r old < "$cache" || old=0
    printf %d\\n "$sum" > "$cache"
    printf %d\\n $(( sum - old ))
}

network_print() {
    connection_list=$(nmcli -t -f name,type,device,state connection show --order name --active 2>/dev/null | grep -v ':bridge:')
    counter=0

    if [ -n "$connection_list" ] && [ "$(echo "$connection_list" | wc -l)" -gt 0  ]; then
        echo "$connection_list" | while read -r line; do
            description=$(echo "$line" | sed -e 's/\\:/-/g' | cut -d ':' -f 1)
            type=$(echo "$line" | sed -e 's/\\:/-/g' | cut -d ':' -f 2)
            device=$(echo "$line" | sed -e 's/\\:/-/g' | cut -d ':' -f 3)
            state=$(echo "$line" | sed -e 's/\\:/-/g' | cut -d ':' -f 4)

            rx=$(update /sys/class/net/[ew]*/statistics/rx_bytes)
            tx=$(update /sys/class/net/[ew]*/statistics/tx_bytes)

            if [ "$state" = "activated" ]; then
                if [ "$type" = "802-11-wireless" ]; then

                    signal=$(nmcli -t -f in-use,signal device wifi list ifname "$device" | grep "\*" | cut -d ':' -f 2)
                    if [ "$signal" -lt 40 ]; then
                        icon="#1"
                        # description="$info- %{F#f9cc18}$signal%%{F-}"
                        # info=$(printf "D %dKiB U %dKiB" "$rx" "$tx")
                        info=$(printf "D %3sB U %3sB\\n" $(numfmt --to=iec $rx) $(numfmt --to=iec $tx))
                      else
                        icon="#11"
                        # description="$info - %{F#f9cc18}$signal%%{F-}"
                        # info=$(printf "D %dKiB U %dKiB" "$rx" "$tx")
                        info=$(printf "D %3sB U %3sB\\n" $(numfmt --to=iec $rx) $(numfmt --to=iec $tx))
                        desc="$info [$signal]"
                    fi
                elif [ "$type" = "802-3-ethernet" ]; then
                    icon="#2"

                    speed="$(cat /sys/class/net/"$device"/speed)"
                    if [ "$speed" -ne -1 ]; then
                        if [ "$speed" -eq 1000 ]; then
                            speed="1G"
                        else
                            speed=$speed"M"
                        fi
                    else
                        speed="?"
                    fi

                    description="$description ($speed)"
                elif [ "$type" = "bluetooth" ]; then
                    icon="#3"

                    description="$description"
                fi
            fi

            if [ $counter -gt 0 ]; then
                printf "  %s %s" "$icon" "$desc"
            else
                printf "%s %s" "$icon" "$desc"
            fi

            counter=$((counter + 1))
        done

        printf "\n"
    else
        echo "#3"
    fi
}



case "$1" in
    --update)
        update
        ;;
    *)
        # echo $$ > $path_pid

        trap exit INT
        trap "echo" USR1

        while true; do
            network_print

            sleep 1 &
            wait
        done
        ;;
esac
