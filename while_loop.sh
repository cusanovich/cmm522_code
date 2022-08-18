#!/bin/bash
x=1
while  [ $x -le 5 ]
do
	echo "I plan to publish $x papers in grad school"
	x=$(( x+1 ))
done
