_volume() {
    status=$(amixer get Master | grep "Mono: P" | awk '{print $6}')
    if [ "$status" = "[on]" ] ; then
	volume=$(amixer get Master | grep "Mono: P" | awk '{print $4}' | grep -oE "[[:digit:]]{1,}"%)
	volume=`echo -e "\x06[$volume]"`
    else
	volume="mute"
	volume=`echo -e "\x06[$volume]"`
    fi
}

_heure() {
    heure=$(date '+%Hh %Mm')
    heure=`echo -e "\x05[$heure]"`
}

_date() {
    date=$(date '+%A %d %B')
    date=`echo -e "\x01[$date]"`
}

_uptime() {
    uptime=$(cut -d'.' -f1 /proc/uptime)
    mins=$((${uptime}/60%60))
    hours=$((${uptime}/3600%24))
    days=$((${uptime}/86400))
    uptime="${mins}m"
    if [ "${hours}" -ne "0" ]; then
	uptime="${hours}h ${uptime}"
    fi
    if [ "${days}" -ne "0" ]; then
	uptime="${days}d ${uptime}"
    fi
    uptime=`echo -e "\x06[$uptime]"`
}

_kernel() {
    kernel=`uname -r`
    kernel=`echo -e "\x05[$kernel]"`
}

_moc() {
    if [ -z $(mocp -Q %state | grep PLAY) ]; then
	mus="off"
	moc=`echo -e "\x01[$mus]"`
    else
	art=$(mocp -Q %artist)
	tit=$(mocp -Q %song)
	if [ $(echo "$art - $tit" | wc -m) -gt "99" ]; then
	    mus=$(echo "$art - $tit"  | cut -b 1-99)
	    moc=`echo -e "\x01[$mus...]"`
	else
	    mus="$art - $tit"
	    moc=`echo -e "\x01[$mus]"`
	fi
    fi
}

status() {
    for arg in $@; do
	_${arg}
	args="${args}  `eval echo '$'$arg`"
    done
    echo "$args"
}

status moc kernel uptime date heure volume
