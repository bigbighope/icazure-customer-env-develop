#!/bin/bash

source parameters.sh

number=${NumberOfNodes}

if  [  $number -lt 10 ]; then
NodeName="Node0"$number
else
NodeName="Node"$number
fi

TGT_LOGON="${!NodeName}/dbc,${TDPassword}"

echo $TGT_LOGON


echo "Checking if the  TEST_BACKUP_01 from Database TEST_DB is restored----------"

sleep 3

function check_restored_table
{
bteq << EOJ
.LOGON ${TGT_LOGON};
.FORMAT OFF;
.SET HEADING " ";
.TITLEDASHES OFF;
.SET WIDTH 1000;

.EXPORT REPORT FILE=$HOME/logs/Teradata_Table_List_After_Restore_$DATE;

SELECT TABLENAME FROM DBC.TABLES WHERE DATABASENAME='TEST_DB';

.If Errorcode <> 0  Then .goto Error

.Lable Error
.logoff
.quit 0
EOJ

}

check_restored_table ;