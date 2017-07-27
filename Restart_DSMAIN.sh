#!/bin/bash
source parameters.sh

number=${NumberOfNodes}

if  [  $number -lt 10 ]; then
NodeName="Node0"$number
else
NodeName="Node"$number

fi

echo "DSMAIN Service restarting ----------"

sudo ssh -i key.pem ec2-user@${!NodeName} "sudo sh -c \"echo 'start bardsmain -s'> /root/sp_ds\""
sudo ssh -i key.pem ec2-user@${!NodeName} "sudo sh -c \"echo 'start bardsmain'> /root/st_ds\""

STILLRUNNING=1
STOPPED=0

while [ ${STILLRUNNING} -gt 0 ]
 do

   sudo ssh -i key.pem ec2-user@${!NodeName} "sudo cnscons -s /root/sp_ds" 
   sleep 5
   sudo ssh -i key.pem ec2-user@${!NodeName} "sudo ps -ef | grep dsmain" > $HOME/logs/DSMAIN_Stop_$DATE
   STOP=`grep teradata $HOME/logs/DSMAIN_Stop_$DATE | wc -l`

      if [ ${STOP} -eq 0 ]
		then
		STILLRUNNING=0
     		echo "DSMAIN service stopped for restart at Teradata last node ----------- " >> $HOME/logs/Test_Results_$DATE
      else 
                echo "ERR!!!DSMAIN service not stopped ,trying to stop again! ---------- " >> $HOME/logs/Test_Results_$DATE
      fi

done

echo "DSMAIN Service stopped ----------"

sleep 5

RUNNING=1
START=0

while [ ${RUNNING} -gt 0 ]
 do

   sudo ssh -i key.pem ec2-user@${!NodeName} "sudo cnscons -s /root/st_ds"
   sleep 5
   sudo ssh -i key.pem ec2-user@${!NodeName} "sudo ps -ef | grep dsmain" > $HOME/logs/DSMAIN_Start_$DATE
   START=`grep teradata $HOME/logs/DSMAIN_Start_$DATE | wc -l`
      
      if [ ${START} -gt 0 ]
                then
                RUNNING=0
                echo "DSMAIN service started at Teradata last node ---------- " >> $HOME/logs/Test_Results_$DATE
      else 
                echo "ERR!!!DSMAIN service not started ,trying to restart again! ---------- " >> $HOME/logs/Test_Results_$DATE
      fi

done

echo "DSMAIN Service re-started ----------"

sleep 5
