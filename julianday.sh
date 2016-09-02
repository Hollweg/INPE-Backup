#/bin/bash
#
#Software para calculo do dia juliano
#Desenvolvido por Guilherme Hollweg 
#Ultima modificacao 08/2016
#
echo " "
echo "Acessing server to acquire actual date"

ssh root@server "date +%e > date.txt ; date +%m >> date.txt ; date +%y >> date.txt"
ssh root@server 'day=`cat date.txt | head -n1`; month=`cat date.txt | tail -n2 | head -n1`; year=`cat date.txt | tail -n1`; 
echo day: $day month: $month and year: 20$year' > /$pathLocal/backup.txt

day=`cat /$pathLocal/backup.txt | cut -f2 -d" "` ;
month=`cat /$pathLocal/backup.txt | cut -f4 -d" "` ;
year=`cat /$pathLocal/backup.txt | cut -f7 -d" "` ;

echo "Selected date: $day-$month-$year"

# Verify if the year is leap
if test `expr $year % 4` -eq 0
then
	if test `expr $year % 100` -eq 0
	then
		if test `expr $year % 400` -eq 0
		then
			leap=1
		else
			leap=0
		fi
	else
		leap=1
	fi
else
	leap=0
fi

if test $leap -eq 0
then
	febDays=28
else
	febDays=29
fi

case $month in
	01) julianDay=`expr $day`;;
	02) julianDay=`expr 31 + $day`;;
	03) julianDay=`expr 31 + $febDays + $day`;;
	04) julianDay=`expr 31 + $febDays + 31 + $day`;;
	05) julianDay=`expr 31 + $febDays + 31 + 30 + $day`;;
	06) julianDay=`expr 31 + $febDays + 31 + 30 + 31 + $day`;;
	07) julianDay=`expr 31 + $febDays + 31 + 30 + 31 + 30 + $day`;;
	08) julianDay=`expr 31 + $febDays + 31 + 30 + 31 + 30 + 31 + $day`;;
	09) julianDay=`expr 31 + $febDays + 31 + 30 + 31 + 30 + 31 + 31 + $day`;;
	10) julianDay=`expr 31 + $febDays + 31 + 30 + 31 + 30 + 31 + 31 + 30 + $day`;;
	11) julianDay=`expr 31 + $febDays + 31 + 30 + 31 + 30 + 31 + 31 + 30 + 31 + $day`;;
	12) julianDay=`expr 31 + $febDays + 31 + 30 + 31 + 30 + 31 + 31 + 30 + 31 + 30 + $day`;;
esac

echo "Selected date: $day-$month-$year corresponding to julian day $julianDay" 
echo "Deleting generated files... "
ssh root@server "rm -rf ~/date.txt"

echo "Done!"

exit 
