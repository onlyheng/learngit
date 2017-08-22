#!/bin/bash
time=21
day=3
month=8
year=2017
if [ $[$year % 4] -eq 0  -a $[$year % 100] -ne 0 -o $[$year % 400] -eq 0 ]
then 
	two_month=29
else 
	two_month=28
fi
declare -a days=(' ' 31 ${two_month} 31 30 31 30 31 31 30 31 30 31)
if [ "$day" -lt "$time" ]
then 
	let day=${time}-${day}
	echo $year $month $day
	if [ "$month"  -ne "1" ]
	then
		let month=${month}-1;
		let day=${days[${month}]}-${day}
		echo $year $month $day
	else
		let day=${days[12]}-${day}
		let year=${year}-1
		month=12	
		echo $year $month $day
	fi
else
	let day=${day}-${time}
	echo $year $month $day
fi
echo $year $month $day
SnapTime="${year}-${month}-${day}"
echo $SnapTime
