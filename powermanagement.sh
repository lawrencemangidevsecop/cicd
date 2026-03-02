#!/bin/bash

wait_time=15

while true;do
    if acpi -a | grep -q "off-line" ; then

wall "power lost ! server shutting down in  $wait_time seconds. type 'sudo shutdown -c' to stop it"

sleep $wait_time
  if acpi -a | grep -q "off-line"; then 
    wall "power still out . killing processes and sycing disk..."
    wall "pwer lost! gracefully shutting down any running containers...."
    docker stop $(docker ps -q)
    wall "container shut down successfully"
    sleep 5

     sync
     sudo shutdown -h now
     else

     wall "power restored shutdown aborted"
     fi
fi
sleep 5
done

