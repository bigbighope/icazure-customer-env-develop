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


echo "Creating Teradata Database TEST_DB and tables with data for back up and restore----------"



function create_db_tables
{
bteq << EOJ
.LOGON ${TGT_LOGON};
.FORMAT OFF;
.SET HEADING " ";
.TITLEDASHES OFF;
.SET WIDTH 1000;

.EXPORT REPORT FILE=$HOME/logs/Teradata_Table_List_Before_Backup_$DATE;

CREATE DATABASE TEST_DB FROM dbc AS PERMANENT = 20e9, SPOOL = 200e6;

CREATE TABLE TEST_DB.TEST_BACKUP ( NUMBER_01 INT,NUMBER_02 INT);

INSERT INTO TEST_DB.TEST_BACKUP VALUES(1,2);
INSERT INTO TEST_DB.TEST_BACKUP VALUES(3,4);
INSERT INTO TEST_DB.TEST_BACKUP VALUES(5,6);
INSERT INTO TEST_DB.TEST_BACKUP VALUES(7,8);


CREATE TABLE TEST_DB.TEST_BACKUP_01 ( NUMBER_01 INT,NUMBER_02 INT);

INSERT INTO TEST_DB.TEST_BACKUP_01 VALUES(9,10);
INSERT INTO TEST_DB.TEST_BACKUP_01 VALUES(11,12);
INSERT INTO TEST_DB.TEST_BACKUP_01 VALUES(13,14);
INSERT INTO TEST_DB.TEST_BACKUP_01 VALUES(15,16);


SELECT TABLENAME FROM DBC.TABLES WHERE DATABASENAME='TEST_DB';

.If Errorcode <> 0  Then .goto Error

.Lable Error
.logoff
.quit 0
EOJ

}

create_db_tables ;


echo "Database TEST_DB with Table TEST_BACKUP & TEST_BACKUP_01 created and populated with sample data " >> $HOME/logs/Test_Results_$DATE
