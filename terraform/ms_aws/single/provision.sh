#!/bin/bash

DEVICE_NAME="/dev/xvdi"

MOUNT_POINT="/opt"

LOG_FILE="$HOME/provision.log"

if [ ! -d "$MOUNT_POINT" ]
then
  echo "Creating mount point $MOUNT_POINT" > $LOG_FILE
  mkdir $MOUNT_POINT
else
  echo "Mount point $MOUNT_POINT exists" >> $LOG_FILE
fi

if [ `ls -A /opt/ | wc -m` = "0" ]; then
    echo "Mount Point $MOUNT_POINT is empty" >> $LOG_FILE
else
    echo "Mount Point $MOUNT_POINT is not empty using different moount point" >> $LOG_FILE
    mkdir /mnt/tmp 2>> $LOG_FILE
    MOUNT_POINT="/mnt/tmp"
fi

ISMOUNTED=`/bin/mount | grep -w "^$DEVICE_NAME"`
IS_FORMATTED=`/usr/bin/file -s /$DEVICE_NAME | awk -F: '{print $NF}'`

if [ "$ISMOUNTED" = "" ]
then
  if [ "$IS_FORMATTED" = " data" ]
  then
    echo "Creating filesystem on device $DEVICE_NAME" >> $LOG_FILE
    /sbin/mkfs -t ext4 $DEVICE_NAME >> $LOG_FILE
  else
    echo "Device is already formatted" >> $LOG_FILE
  fi

  echo "Mounting Filesystem $DEVICE_NAME on $MOUNT_POINT" >> $LOG_FILE
  /bin/mount $DEVICE_NAME $MOUNT_POINT

  if [ $? -eq 0 ];then
     echo "Device $DEVICE_NAME mounted succesfully" >> $LOG_FILE
  else
     echo "Device $DEVICE_NAME mount failed" >> $LOG_FILE
  fi
else
  echo "Device $DEVICE_NAME already mounted" >> $LOG_FILE
fi

