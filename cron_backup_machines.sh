#!/bin/bash

echo " "
echo "#######      Cluster VMs Backup Script        #######" 
echo "#######   Developed by Guilherme Hollweg      #######"
echo "#######        Last Update: 03/2017           #######"
echo " "
echo "Virtual Machines backup started in `date "+%x %X"`"
echo " "

echo "Virsh real state in (`date "+%x %X"`): "
echo " "
virsh list --all
upMachines=`virsh list | grep maq | wc -l	`

echo "Shutting down the following machines... (`date "+%x %X"`)"
#Testing the right field to cut
if [[ $(virsh list | grep maq | cut -f6 -d" ") ]]; then
    virsh list | grep maq | cut -f6 -d" " > /$pathVirt/VMs_on ;
else
    virsh list | grep maq | cut -f5 -d" " > /$pathVirt/VMs_on ;
fi

cat /$pathVirt/VMs_on;
echo " "

for machine in `cat /$pathVirt/VMs_on`
do
    virsh shutdown $machine
done

stillUp=`virsh list | grep maq | wc -l`
echo "Number of machines ON: $stillUp"
while [ $stillUp -ne 0 ]
do
    sleep 12
    stillUp=`virsh list | grep maq | wc -l`
    echo "Number of machines ON: $stillUp"
done

echo " "
echo "Machines OFF in (`date "+%x %X"`)!"
echo " "
echo "Virsh real state in (`date "+%x %X"`): "
echo " "
virsh list --all

# Copy all the machine names to a file called temp, with some null lines, then, grep by maq and save the 
# correct machine names in /root/all_VMs
virsh list --all | grep maq | cut -f7 -d" " > /$pathVirt/temp ; 
virsh list --all | grep maq | cut -f6 -d" " >> /$pathVirt/temp ; 
cat /$pathVirt/temp | grep maq > /$pathVirt/all_VMs ; 
rm -f /$pathVirt/temp ;

echo "Preparing to copy .imgs to backup folder (`date "+%x %X"`)"
echo " "
dirName=`date | cut -d " " -f1,2,3,4,5,6,7 | sed -e 's/  /-/g' | sed -e 's/ /-/g'`

echo "Virtual machines (.img) to copy:"
cat /$pathVirt/all_VMs ;
echo " "

echo "Removing old backup to free space..."
echo " "
rm -rf /$pathVirtBackup/

echo "Creating new backup folder in /virtualmachines/BACKUP-VMs ..."
echo " "
mkdir /$pathVirtBackup/ 
mkdir /$pathVirtBackup/$dirName

for img in `cat /$pathVirt/all_VMs`
do
	echo "Copying virtual machine $img..."
    cp -v /$pathVirtVMS/$img.img /$pathVirtBackup/$dirName
    echo " "
done

echo "Backup done in (`date "+%x %X"`)!"
echo " "
echo "ls /$pathVirtBackup/$dirName"
echo " "
ls /$pathVirtBackup/$dirName
echo " "

echo "Initializing VMs in (`date "+%x %X"`)"
echo " "
for machine in `cat /$pathVirt/VMs_on`
do
    virsh start $machine
done

startedMachines=`virsh list | grep maq | wc -l`
echo "Number of started Machines: $startedMachines"
while [ $startedMachines -ne $upMachines ]
do
    sleep 12
    startedMachines=`virsh list | grep maq | wc -l`
    echo "Number of started Machines: $startedMachines"
done

echo "Machines ON in (`date "+%x %X"`)!"
echo " "
echo "Virsh real state in (`date "+%x %X"`): "
echo " "
virsh list --all

rm -f /$pathVirt/VMs_on /$pathVirt/all_VMs
echo "All done in (`date "+%x %X"`)!"
echo " "
