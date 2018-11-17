#!/bin/bash
mkfs -t ext4 /dev/xvdi
mount /dev/xvdi /opt
echo /dev/xvdi  /opt ext4 defaults,nofail 0 2 >> /etc/fstab
