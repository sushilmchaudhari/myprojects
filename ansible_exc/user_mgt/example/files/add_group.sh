#!/bin/bash

group_names=`echo $* | sed 's/,/ /g'`

for i in $group_names
do
     if [ ! $(getent group $i) ]; then
	/usr/sbin/groupadd $i
     fi
done

