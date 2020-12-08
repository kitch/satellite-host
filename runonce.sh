#!/bin/bash

if [ -e /tmp/runonce ]
then
   rm /tmp/runonce
   exec > /root/runonce.log 2>&1
   /root/satellite-hosts.sh
fi

exit
