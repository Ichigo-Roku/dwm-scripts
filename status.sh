_bat() {
    bat=`cat /sys/class/power_supply/BAT0/capacity`
    bat=`echo -e "\x06[$bat%]"`
}

_volume() {
    status=$(amixer get Master | grep "Mono: P" | awk '{print $6}')
    if [ "$status" = "[on]" ] ; then
	volume=$(amixer get Master | grep "Mono: P" | awk '{print $4}' | grep -oE "[[:digit:]]{1,}"%)
	volume=`echo -e "\x05[$volume]"`
    else
	volume="mute"
	volume=`echo -e "\x05[$volume]"`
    fi
}

_heure() {
    heure=$(date '+%I:%M %p')
    heure=`echo -e "\x01[$heure]"`
}

_date() {
    date=$(date '+%A, %B %d')
    date=`echo -e "\x06[$date]"`
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
    uptime=`echo -e "\x05[$uptime]"`
}

_kernel() {
    kernel=`uname -r`
    kernel=`echo -e "\x01[$kernel]"`
}

_moc() {
    if [ -z $(mocp -Q %state | grep PLAY) ]; then
	mus="off"
	moc=`echo -e "\x06[$mus]"`
    else
	art=$(mocp -Q %artist)
	tit=$(mocp -Q %song)
	if [ $(echo "$art - $tit" | wc -m) -gt "99" ]; then
	    mus=$(echo "$art - $tit"  | cut -b 1-99)
	    moc=`echo -e "\x06[$mus...]"`
	else
	    mus="$art - $tit"
	    moc=`echo -e "\x06[$mus]"`
	fi
    fi
}

_bright() {
    max=`cat /sys/class/backlight/intel_backlight/max_brightness`
    actual=`cat /sys/class/backlight/intel_backlight/actual_brightness`
    bright=`echo $(( ($actual * 100) / $max ))`
    bright=`echo -e "\x05[$bright%]"`
}

_light() {
    max=`cat /sys/class/leds/smc::kbd_backlight/max_brightness`
    actual=`cat /sys/class/leds/smc::kbd_backlight/brightness`
    light=`echo $(( ($actual * 100) / $max ))`
    light=`echo -e "\x01[$light%]"`
}

status() {
    for arg in $@; do
	_${arg}
	args="${args}  `eval echo '$'$arg`"
    done
    echo "$args"
}

status light bright moc kernel uptime date heure volume bat
