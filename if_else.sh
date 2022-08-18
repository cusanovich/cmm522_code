#!/bin/bash
today=`date +'%B %d'`
dom=`date +'%d'`
if [ $dom -le 31 ]
then
	echo "Today is ${today}. It is a good day to learn bioinformatics."
else
	echo "Today is ${today}. It is a bad day to learn bioinformatics."
fi
