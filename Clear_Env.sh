#!/bin/bash

source parameters.sh

number=${NumberOfNodes}

if  [  $number -lt 10 ]; then
NodeName="Node0"$number
else
NodeName="Node"$number

fi

TGT_LOGON="${!NodeName}/dbc,${TDPassword}"

echo "Deleting tables and database from Teradata system----------"

sleep 3

function drop_db_tables
{
bteq << EOJ
.LOGON ${TGT_LOGON};
.FORMAT OFF;
.SET HEADING " ";
.TITLEDASHES OFF;
.SET WIDTH 1000;

.EXPORT REPORT FILE=$HOME/logs/Teradata_Table_List_After_Restore_$DATE;

DROP TABLE TEST_DB.TEST_BACKUP;
DROP TABLE TEST_DB.TEST_BACKUP_01;
DROP DATABASE TEST_DB;

.If Errorcode <> 0  Then .goto Error

.Lable Error
.logoff
.quit 0
EOJ

}

drop_db_tables ;


sleep 3
dsc retire_job -n RES_DB_TEST_DB -S
sleep 3
dsc delete_job -n RES_DB_TEST_DB -S
sleep 3
dsc retire_job -n Bkp_DB_TEST_DB -S
sleep 3
dsc delete_job -n Bkp_DB_TEST_DB -S



