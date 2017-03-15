#/bin/bash

echo " "
echo "#######    Cluster Backup Script        #######" 
echo "####### Developed by Guilherme Hollweg  #######"
echo "#######    Last Update: 03/2017         #######"
echo " "
echo "Acquiring Julian Day and server date..."

#Find the julian day 
julianDay=`$pathLocal | grep julian | cut -f8 -d" "`    

day=`cat /$pathLocal/$file | cut -f2 -d" "`
month=`cat /pathLocal/$file | cut -f4 -d" "`
year=`cat /$pathLocal/$file | cut -f7 -d" "`
lastyear=`expr $year - 1`
leap=`expr $lastyear % 4`
flagYear=0

#Test if julian day is 01 or 02 and year is leap
#If positive have to find the last last julian day
if test $julianDay -eq 01
then
    if test $leap -eq 0
    then
        lastLastJulianDay=365
    else
        lastLastJulianDay=364
    fi
    onelastLastJulianDay=`expr $lastLastJulianDay - 1`
    twolastLastJulianDay=`expr $lastLastJulianDay - 2`
elif test $julianDay -eq 02
then
    if test $leap -eq 0
    then
        lastLastJulianDay=366
    else
        lastLastJulianDay=365
    fi
    onelastLastJulianDay=`expr $lastLastJulianDay - 1`
    twolastLastJulianDay=`expr $lastLastJulianDay - 2`
elif test $julianDay -eq 03
then
    lastLastJulianDay=01
    if test $leap -eq 0
    then
        onelastLastJulianDay=366
        twolastLastJulianDay=365
    else
        onelastLastJulianDay=365
        twolastLastJulianDay=364
    fi
elif test $julianDay -eq 04
then
    lastLastJulianDay=02
    onelastLastJulianDay=01
    if test $leap -eq 0
    then
        twolastLastJulianDay=366
    else
        twolastLastJulianDay=365       
    fi
else
    lastLastJulianDay=`expr $julianDay - 2`
    onelastLastJulianDay=`expr $lastLastJulianDay - 1`
    twolastLastJulianDay=`expr $lastLastJulianDay - 2`
fi

echo "Day:$day Month:$month Year:$year. "
echo "Last last Julian Day:$lastLastJulianDay"

#Acess cluster to find the last folder in local backup
ssh root@cluster "cd /$pathCluster/$year/ ; ls -lrt | tail -n1 | rev | cut -f1 -d' ' | rev > ../backup.txt"
ssh root@cluster 'cd /$pathCluster/ ; lastFolder=`cat backup.txt | head -n1` ; echo Last Folder: $lastFolder ' > /$pathLocal/backup.txt
lastFolder=`cat /$pathLocal/backup.txt | cut -f3 -d" "`

echo " "
echo "Acessing cluster to check the backup files..."
echo "Last folder to be copy: $lastLastJulianDay."
echo "Last folder found on cluster: $lastFolder."

cd /$pathBackup ;
#Tests if last folder found in cluster corresponds to julian day -2 (according SUPIM simulation)
if test $lastFolder -eq $lastLastJulianDay
then
    echo " "
    echo "Folder $lastLastJulianDay ready to be copy"
    #Verify if the folder relative to actual year exists
    if [ -d "$year" ];
    then 
	    echo "Verifying the existence of folder $year... Folder relative to year $year found." 
    else
	    echo "Folder $year not found. Creating folder relative to year $year..."
        mkdir $year/
	    echo "Done!"
    fi

    cd $year/
    #Tests if the last folder found in local backup (cluster) exists in backup machine
    if [ -d "$lastLastJulianDay" ];
    then 
	    echo "Folder relative to day $lastLastJulianDay exists in backup machine."
	    echo "No new data to be copy."
    else
	    echo "Copying data relative to day $lastLastJulianDay..."
	    echo " "
	    cd ..
	    scp -r root@cluster:/$pathCluster/$year/$lastFolder/ ./$year/$lastLastJulianDay/
        echo "Listing new folder..."
        echo "ls ./$year/$lastLastJulianDay/"
        ls ./$year/$lastLastJulianDay/
        echo " "
	    echo "Done!."
    fi
else
    echo "Last folder in local backup different than last last julian day."
    echo "No data to be copy."
fi

echo " "
echo "Actual Julian Day backup done!"

#Actual Backup done.

#Check 2 days later
#Verify old folders in backup
echo " "
echo "Checking the folders corresponding to day $onelastLastJulianDay and $twolastLastJulianDay in current folder."

#Verify if it is needed to change the year folder to acquire -3 and -4 julian days
#ex: julian day = 4 ---> sim = 2 ; one last last = 1 and two last last = 366 or 365 (last year)
if test $julianDay -lt 5
then
    if test $onelastLastJulianDay -gt 362
    then
	    cd /$pathBackup/$lastyear/ ;
	    flagYear=1
    else
 	    cd /$pathBackup/$year/ ;
	    flagYear=0
    fi
else 
    cd /$pathBackup/$year/ ;
fi

#check for existence of julian day -1 folder in backup machine
if [ -d "$onelastLastJulianDay" ];
then 
    echo "Folder relative to day $onelastLastJulianDay found!"
else
    #If the folder did not exists in backup, check if it exists in local backup (cluster)
    #Tests de flagYear var to choose what folder to check in cluster
    echo "Missing folder relative to day $onelastLastJulianDay in backup machine."
    if test $flagYear -eq 1
    then 
        ssh root@cluster "cd /$pathCluster/$lastyear ; if [ -d "$onelastLastJulianDay" ]; then echo 1 ; else echo 0 ; fi" > /$pathLocal/backup.txt
    else
        ssh root@cluster "cd /$pathCluster/$year ; if [ -d "$onelastLastJulianDay" ]; then echo 1 ; else echo 0 ; fi" > /$pathLocal/backup.txt
    fi
    oldFolder=`cat /$pathLocal/backup.txt | head -n1`

    #Check the existence of the folder in local backup (cluster)
    if test $oldFolder -eq 1
    then 
	    echo "Folder $onelastLastJulianDay found in local backup (cluster)"
	    echo "Copying data..."
	    echo " "
	    if test $flagYear -eq 1
	    then
            	scp -r root@cluster:/$pathCluster/$lastyear/$onelastLastJulianDay/ ./$onelastLastJulianDay/ 
	    else
	        scp -r root@cluster:/$pathCluster/$year/$onelastLastJulianDay/ ./$onelastLastJulianDay/ 
	    fi
        echo "Listing new folder..."
        echo "ls ./$onelastLastJulianDay/"
        ls ./$onelastLastJulianDay/
        echo " "
	    echo "Done!" 
	    echo " "
    else
	    echo "Folder $onelastLastJulianDay did not exists in local backup (cluster)."
	    echo "No data to copy!"
    fi
fi

#check for existence of julian day -2 folder in backup machine
#ex: it is possible to have the situation: julian day 4; backup sim day = 2 ; one last last = 1 and two last last 366 or 365
if test $onelastLastJulianDay -eq 1
then
    cd /$pathBackup/$lastyear/ ;
    flagYear=1
else
    cd /$pathBackup/$year/ ;
    flagYear=0
fi

if [ -d "$twolastLastJulianDay" ];
then 
    echo "Folder relative to day $twolastLastJulianDay found!"
else
    #If the folder did not exists in backup, check if it exists in local backup (cluster)
    echo "Missing folder relative to day $twolastLastJulianDay in backup machine."
    
    if test $flagYear -eq 1
    then 
	   ssh root@cluster "cd /$pathCluster/$lastyear ; if [ -d "$twolastLastJulianDay" ]; then echo 1 ; else echo 0 ; fi" > /$pathLocal/backup.txt
    else
	   ssh root@cluster "cd /$pathCluster/$year ; if [ -d "$twolastLastJulianDay" ]; then echo 1 ; else echo 0 ; fi" > /$pathLocal/backup.txt
    fi
    
    oldFolder=`cat /$pathLocal/backup.txt | head -n1`

    #Check the existence of the folder in local backup (cluster)
    if test $oldFolder -eq 1
    then
        echo "Folder $twolastLastJulianDay found in local backup (cluster)"
        echo "Copying data..."
	    echo " "
	    if test $flagYear -eq 1
	    then
            scp -r root@cluster:/$pathCluster/$lastyear/$twolastLastJulianDay/ ./$twolastLastJulianDay/ 
	    else
            scp -r root@cluster:/$pathCluster/$year/$twolastLastJulianDay/ ./$twolastLastJulianDay/
        fi
        echo "Listing new folder..."
        echo "ls ./$twolastLastJulianDay/"
        ls ./$twolastLastJulianDay/
        echo " "
	    echo "Done!"
    else
        echo "Folder $twolastLastJulianDay did not exists in local backup (cluster)."        
        echo "No data to copy!"
    fi
fi

echo " "
echo "Deleting obsolete files..."
echo "All done!"

if test $flagYear -eq 1
then
    rm -rf /$pathLocal/backup.txt /$pathLocal/$lastyear/backup.txt
    ssh root@cluster "cd /$pathCluster/$lastyear/ ; rm -rf backup.txt"
else 
    rm -rf /$pathLocal/backup.txt /$pathLocal/$year/backup.txt
    ssh root@cluster "cd /$pathCluster/$year/ ; rm -rf backup.txt"
fi

echo " "
echo "End of backup" 
