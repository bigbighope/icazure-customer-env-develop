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


echo "Dropping one of the table TEST_BACKUP_01 from Database TEST_DB for back up and restore testing----------"

sleep 3

function drop_table
{
bteq << EOJ
.LOGON ${TGT_LOGON};
.FORMAT OFF;
.SET HEADING " ";
.TITLEDASHES OFF;
.SET WIDTH 1000;

.EXPORT REPORT FILE=$HOME/logs/Teradata_Table_List_After_Table_Deletion_$DATE;

DROP TABLE TEST_DB.TEST_BACKUP_01;

SELECT TABLENAME FROM DBC.TABLES WHERE DATABASENAME='TEST_DB';

.If Errorcode <> 0  Then .goto Error

.Lable Error
.logoff
.quit 0
EOJ

}

drop_table ;


echo "Dropped one of the table TEST_BACKUP_01 from Database TEST_DB for back up and restore testing---------- " >> $HOME/logs/Test_Results_$DATE
