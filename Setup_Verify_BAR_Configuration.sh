#!/bin/bash

#exit the entire script for nonzero exit code
set -e

source parameters.sh

Log_Path=$HOME/logs
Log_File=$Log_Path/Test_Results_$DATE

if [ ! -d $Log_Path ]; then
    mkdir -p $Log_Path;
fi

if [ ! -d $Log_File ]; then
    touch $Log_File
fi

echo "*************************************************************************************************************************"
echo "Clearing obsolete files ..."
if [ -e Config_System.xml ]; then
    rm Config_System.xml
    sleep 2
fi

if [ -e Config_Azure.xml ]; then
    rm Config_Azure.xml
    sleep 2
fi

if [ -e Config_TargetGroups_Azure.xml ]; then
    rm Config_TargetGroups_Azure.xml
    sleep 2
fi

if [ -e ${RestoreJobName}.xml ]; then
    rm ${RestoreJobName}.xml
    sleep 2
fi

if [ -e ${BackupJobName}.xml ]; then
    rm ${BackupJobName}.xml
    sleep 2
fi

echo "*************************************************************************************************************************"
echo "Preparing XML files ..." 
sh ./Prepare_Config_System_XML.sh
sleep 3

sh ./Prepare_Config_Azure_XML.sh
sleep 3

sh ./Prepare_Config_TargetGroups_Azure_XML.sh
sleep 3

sh ./Prepare_Backup_XML.sh
sleep 3

sh ./Prepare_Restore_XML.sh
sleep 3

echo "XML file generated for Teradata system and all nodes configuration---------- " >> $Log_File

echo "*************************************************************************************************************************"
echo "Updating passwords in dsu-init ..."
DSU_Init=/opt/teradata/client/${DatabaseVersion}/dsa/commandline/dsu-init
sudo sed -i -e "/DBC_DEF_PASS/ s/='[^'][^']*'/='${DBCPassword}'/" -e "/ADMIN_DEF_PASS/ s/='[^'][^']*'/='${DSCAdminPassword}'/" $DSU_Init
echo "Updated DBC_DEF_PASS and ADMIN_DEF_PASS settings for dsu-init ---------- " >> $Log_File

echo "*************************************************************************************************************************"
echo "Initializing dsu ..."
printf "${ViewpointSubNetAddress}\ny" | sudo $DSU_Init
sleep 5
echo "Initialized dsu ---------- " >> $Log_File

echo "*************************************************************************************************************************"
echo "Applying Config_System.xml ..."
printf "dbc\n${DBCPassword}\n" | dsc config_systems -f Config_System.xml
sleep 5

echo "*************************************************************************************************************************"
echo "Applying Config_Azure.xml ..."
printf "n\n${StorageAccountAccessKey}\n" | dsc config_azure -f Config_Azure.xml
sleep 5

echo "*************************************************************************************************************************"
echo "Applying Config_TargetGroups_Azure.xml ..."
dsc config_target_groups -t TARGET_AZURE -f Config_TargetGroups_Azure.xml
sleep 5

echo "*************************************************************************************************************************"
echo "Logging the systems settings into $HOME/logs/DSC_System_Config_log_$DATE and $HOME/logs/DSC_TG_Config_log_$DATE ..."
dsc list_components -type SYSTEM > $HOME/logs/DSC_System_Config_log_$DATE
dsc list_components -type TARGET_GROUP > $HOME/logs/DSC_TG_Config_log_$DATE
echo "Teradata system and all nodes configuration completed---------- " >> $Log_File

echo "*************************************************************************************************************************"
echo "Please login to viewpoint and click the JMS messages Checkbox and update system----------"
read -p "Press Enter once you update the system:... " -n1 -s

echo "*************************************************************************************************************************"
echo "Stopping and Restarting DSMAIN service in a background process..."
sleep 5
printf "start bardsmain -s\nstart bardsmain\n" | sudo cnsterm 6 &
sleep 10

echo "*************************************************************************************************************************"
echo "Killing the background process used to stop and restart DSMAIN ..."
for proc in $(pgrep cnsterm); do sudo kill -INT $proc; done
sleep 3

echo "*************************************************************************************************************************"
echo "Please activate the system at Viewpoint portal----------"
read -p "Press Enter once you activate the system:... " -n1 -s

echo "*************************************************************************************************************************"
echo "Creating Databse and tables to verify BAR configuration ..."
sleep 5
sh ./Create_Database_Tables.sh
sleep 5

echo "*************************************************************************************************************************"
echo "Creating a backup job ..."
sleep 5
printf "dbc\n${DBCPassword}\n" | dsc create_job -f ${BackupJobName}.xml
sleep 3

echo "*************************************************************************************************************************"
echo "Running the backup job ..."
dsc run_job -n ${BackupJobName}

echo "*************************************************************************************************************************"
echo "Verifing the backup job (it takes for 5 minutes) ..."
RUN=1
BACKUP=0

while [ ${RUN} -gt 0 ]
 do
   RUNNING=0
   dsc job_status -n ${BackupJobName} > $HOME/logs/Backup_Job_Log_$DATE
   RUNNING=`grep RUNNING $HOME/logs/Backup_Job_Log_$DATE | wc -l`
   BACKUP=`grep COMPLETED_SUCCESSFULLY $HOME/logs/Backup_Job_Log_$DATE | wc -l`

      if [ ${BACKUP} -gt 0 ]
                then
                RUN=0
                echo "Backup Completed Successfully ---------- "
                echo "Backup Completed Successfully ---------- " >> $Log_File
      elif [ ${BACKUP} -eq 0 ]&& [ ${RUNNING} -eq 0 ]
                then
                RUN=0
                echo "ERR!!!Backup Job Failed,Please check the log ---------- " >> $Log_File	
      fi

done

echo "*************************************************************************************************************************"
echo "Deleting DB_TEST_ for restore testing----------"
sleep 3
sh ./Drop_Table.sh

echo "*************************************************************************************************************************"
echo "Creating a Restore job (${RestoreJobName}) ..."
sleep 5
printf "dbc\n${DBCPassword}\ny\n${DBCPassword}\n" | dsc create_job -f ${RestoreJobName}.xml
sleep 3

echo "*************************************************************************************************************************"
echo "Running the Restore job (${RestoreJobName}) ..."
dsc run_job -n ${RestoreJobName}

RUN_RESTORE=1
RESTORE=0

while [ ${RUN_RESTORE} -gt 0 ]
 do
   RUNNING_RESTORE=0
   dsc job_status -n ${RestoreJobName} > $HOME/logs/Restore_Job_Log_$DATE
   RUNNING_RESTORE=`grep RUNNING $HOME/logs/Restore_Job_Log_$DATE | wc -l`
   RESTORE=`grep COMPLETED_SUCCESSFULLY $HOME/logs/Restore_Job_Log_$DATE | wc -l`

      if [ ${RESTORE} -gt 0 ]
                then
                RUN_RESTORE=0
                echo "Restore Completed Successfully ---------- "
                echo "Restore Completed Successfully ---------- " >> $Log_File
         elif [ ${RESTORE} -eq 0 ]&& [ ${RUNNING_RESTORE} -eq 0 ]
                then
                                RUN_RESTORE=0
                            echo "ERR!!!Restore Job Failed,Please check the log ---------- " >> $Log_File
      fi

done
sleep 5

echo "*************************************************************************************************************************"
echo "Verifing the backup job (it takes for 5 minutes) ..."

#Comment out Check_Restore_Table.sh due to a product bug.
#sh ./Check_Restore_Table.sh

sleep 3
SUCCESS=0
SUCCESS=`grep TEST_BACKUP_01 $HOME/logs/Teradata_Table_List_After_Restore_$DATE | wc -l`

if [ ${SUCCESS} -gt 0 ]
                then
                echo "Restore Completed Successfully ---------- "
                echo "Restore Completed Successfully ---------- " >> $Log_File
         else
               echo "ERR!!!Restore not Completed Successfully"		 
               echo "ERR!!!Restore not Completed Successfully,Please check the log ---------- " >> $Log_File
fi

sleep 5

echo "*************************************************************************************************************************"
echo "Verifing the backup job (it takes for 5 minutes) ..."
sh ./Clear_Env.sh

echo "*************************************************************************************************************************"
echo "Congratulations! All looks good!"