#!/bin/bash
SHELL_NAME="Monitor_Inode.sh"
LOCK_FILE="/tmp/${SHELL_NAME}.lock"
RECORD_STAT="/var/log/Monitor_Inode.log"
SNAPSHOTPATH="/test/snapshot/"
THREADPATH="/data1/NFSHome/NFSv2_1/threaddump/"
savetime=20 

#function Save_90() {
#	find ./NFSHome/snapshot/ -depth -iname "*.zip" -mtime +90 | while read Snapshot_File;do rm -f $Snapshot_File usleep 1000 ;done
#	find ./NFSHome/NFSv2_1/snapshot/ -depth -iname "*.zip" -mtime +90 | while read Snapshot_File;do rm -f $Snapshot_File usleep 1000 ;done
#	Used_Inode;
#}
#function Save_60() {
#	find ./NFSHome/snapshot/ -depth -iname "*.zip" -mtime +60 | while read Snapshot_File;do rm -f $Snapshot_File usleep 1000 ;done 
#	find ./NFSHome/NFSv2_1/snapshot/ -depth -iname "*.zip" -mtime +60 | while read Snapshot_File;do rm -f $Snapshot_File usleep 1000 ;done 
#	Used_Inode;
#}
#function Used_Inode() {
#	Iused_Value=`df -i | awk  '{if($NF=="/data1") print $5 }' | cut -d"%" -f1`
#	if [[ $Iused_Value > 80 ]];then printf "Serious alarm is $Iused_Value\n";Save_60; elif [[ $Iused_Value > 70 ]];then  printf "alarm is $Iused_Value\n "; Save_90;fi
#	printf "\ncurrent Inode is $Iused_Value\n"
#}  
function Del_Empty() {
	ziptime=`date "+%Y%m%d"`
###########################check snapshot directory spacedir
	cd ${SNAPSHOTPATH}
	while true
	do
		flag=0
		find ./ -depth -type d  -empty | while read spacedir
		do
			  rm -rf ${spacedir}
			  usleep 100;
			  echo ${spacedir} >> space.${ziptime}
			  flag=1
		done
		if [ "${flag}" -eq "0" ];then break ;fi
	done
	zip -r  snapshotfile.zip space.${ziptime}
	usleep 100;
	rm -f space.${ziptime};
#########################check threadump directory spacedir
	cd ${THREADPATH}
	while true
	do
		flag=0
		find ./ -depth -type d  -empty | while read spacedir
		do
			rm -rf ${spacedir}
			usleep 100;
			echo ${spacedir} >> space.${ziptime}
			flag=1
		done
		if [ "${flag}" -eq "0" ];then break ;fi
	done
	zip -r threadfile.zip space.${ziptime}
	usleep 100;
	rm -f space
}
##########################backup threadump file
function Bak_Threadfile() {
	ziptime=${1}
	savetime=${2}
	cd ${THREADPATH}
        find ./  -depth -iname "*.zip" -mtime +${savetime} | while read Threadump_File
            do 
                zip -r threadfile.${ziptime}.zip  ${Threadump_File};
                usleep 100;
                rm -f ${Threadump_File};
                usleep 100;
		echo ${Threadump_File} >> file
            done
	zip -r  threadfile.${ziptime}.zip file
	usleep 100;
	rm -f file
	Del_Empty ${ziptime}
}
#########################backup snapshot file
function Bak_Snapfile() {
	ziptime=${1}
        savetime=${2}
	cd {SNAPSHOTPATH}
	find ./  -depth -iname "*.zip" -mtime +${savetime} | while read Snapshot_File
	    do 
		zip -r snapshotfile.${ziptime}.zip  $Snapshot_File ;
		usleep 100;
                rm -f $Snapshot_File;
                usleep 100;
		echo $Snapshot_File >> file
            done
	zip -r snapshotfile.${ziptime}.zip  file
	usleep 100;
	rm -f  file
}
########################get delete file filetime
function Bak_Snapfile_Time() {
time=${1}
#let time=${time}+1
day=`date "+%d"`
month=`date "+%m"`
year=`date "+%Y"`
if [ $[$year % 4] -eq 0  -a $[$year % 100] -ne 0 -o $[$year % 400] -eq 0 ]
then 
	two_month=29
else 
	two_month=28
fi
declare -a days=(' ' 31 ${two_month} 31 30 31 30 31 31 30 31 30 31)
if [ "$((10#${day}))" -lt "$time" ]
then 
	let day=${time}-$((10#${day}))
	let day=${day}-1
	if [ "$((10#$month))"  -ne "1" ]
	then
		let day=${days[$((10#${month}))]}-${day}
		let month=$((10#${month}))-1;
	else
		let day=${days[12]}-${day}
		let year=$((10#${year}))-1
		month=12	
	fi
else
	let day=${day}-${time}
fi
SnapTime="${year}-${month}-${day}"
ThreadTime="${year}-${month}-${day}"
Bak_Snapfile ${SnapTime} ${time};
#Bak_Threadfile ${ThreadTime} ${time};
Del_Empty;
}
######################current time
function Curr_Time() {
	printf "$(date "+%Y-%m-%d") $(date "+%H:%M:%S")\n"
}
# >> $RECORD_STAT
#####################shell lock
function Shell_Lock() {
	touch ${LOCK_FILE}
}
function Shell_unlock() {
	rm -f ${LOCK_FILE}
}
#####################task
function Run_Task() {
#	savetime=20
	savetime=${1}
	Curr_Time;
	Shell_Lock;
	Bak_Snapfile_Time ${savetime};
#	Used_Inode ${savetime};
	Shell_unlock;
}
function Shell_Stat() {
	if [ -f "$LOCK_FILE" ]
	then 
		printf "$SHELL_NAME is running\n"
	else 
		Run_Task ${1};
	fi
}
function main() {
	Shell_Stat ${savetime};
	printf "###########################################\n"
} >> $RECORD_STAT
cd /data1/
main;
