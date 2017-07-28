#!/bin/bash

source parameters.sh

i=${NumberOfNodes}

echo "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>
 <!-- 
 Copyright (C) 2009  by Teradata Corporation.
 All Rights Reserved.
 TERADATA CORPORATION CONFIDENTIAL AND TRADE SECRET 
 -->
<dscConfigSystems
 xmlns=\"http://schemas.teradata.com/v2012/DSC\"
 xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"
 xsi:schemaLocation=\"DSC.xsd\">
	 <system>
	 	<!-- 'system_name' - Required, max 32 characters -->
		<system_name>${SystemName}</system_name>

		<!-- 'tdpid' - Required (unless skipped by option)-->
		<tdpid>${SystemName}</tdpid>

		<!-- 'database_query_method' - Required, accepted values: BASE_VIEW/EXTENDED_VIEW required -->
		<database_query_method>BASE_VIEW</database_query_method>

	 	<!-- 'streams_softlimit' - Required, number of streams per node per job -->
		<streams_softlimit>${StreamLimitForEachJobOnNode}</streams_softlimit>

		<!-- 'streams_hardlimit' - Required, max number of streams per node-->
		<streams_hardlimit>${StreamLimitEachNode}</streams_hardlimit>

		<!-- 'reset_node_limit' - Optional, accepted values: true/false -->
		<reset_node_limit>false</reset_node_limit>

		<!-- 'node', Required (at least one) --> ">>Config_System.xml
for ((number=1;number <= i;number++))
{

if  [  $number -lt 10 ]; then
NodeName="Node0"$number
else
NodeName="Node"$number

fi

IP=${!NodeName}


echo "		<node>
			<!-- 'node_name', Required -->
			<node_name>${NodeName}</node_name>
			
			<!-- 'ip_address' - Required (at least one)-->
			<ip_address>$IP</ip_address>
			
			<!-- 'streams_softlimit' - Optional, number of streams per node for each job -->
			<streams_softlimit>${StreamLimitForEachJobOnNode}</streams_softlimit>
			
			<!-- 'streams_hardlimit' - Optional, max number of streams per node -->
			<streams_hardlimit>${StreamLimitEachNode}</streams_hardlimit>
		</node>">>Config_System.xml
}

echo "		<!--  'skip_force_full' - Optional, accepted values: true/false -->
		<skip_force_full>false</skip_force_full>
	</system>
</dscConfigSystems>">>Config_System.xml

