#!/usr/bin/env bash

function getCPU() {
	percentage=$(mpstat 1 1 | awk '$3 ~ /CPU/ { for(i=1;i<=NF;i++) { if ($i ~ /%idle/) field=i } } $3 ~ /all/ { printf("%d",100 - $field) }')
	padded=$(printf "%2s" $percentage)
	echo -n "$padded%"
}

function getTemp() {
	maxTemp=$(cat /sys/class/thermal/thermal_zone*/temp | sort | tail -1)
	tempCelcius=$(echo "$maxTemp / 1000" | bc)
	echo "$tempCelcius°"
}

function getMemory() {
	totalKB=$(free | head -2 | tail -1 | awk '{ print $2 }')
	availableKB=$(free | head -2 | tail -1 | awk '{ print $7 }')

	usedKB=$(echo "$totalKB - $availableKB" | bc)
	usedMB=$(echo "$usedKB / 1024" | bc)
	usedGB=$(echo "scale=2; $usedKB / 1048576" | bc)

	echo -n "$usedGB"
	echo -n " GB "
}

function getTime() {
	echo -n `date +'%Y-%m-%d %H:%M'`
}

function getBattery() {
	charge=$(cat /sys/class/power_supply/BAT0/charge_now)
	full=$(cat /sys/class/power_supply/BAT0/charge_full)
	let "percentage=100 * $charge / $full"
	echo -n "${percentage}%"
}

# cpu=$(getCPU)
temp=$(getTemp)
mem=$(getMemory)
time=$(getTime)
bat=$(getBattery)
echo "Time:    $time
System:  $temp  $mem
Network: LosAltosHacks
Battery: $bat"

# nix-shell -p python37 --run "python -c \"
# battery = 90;

# print('''bat: {}'''.format(battery))
# \""