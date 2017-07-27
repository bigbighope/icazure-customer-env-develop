#!/bin/bash

source parameters.sh

echo "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>
 <!-- 
 Copyright (C) 2017  by Teradata Corporation.
 All Rights Reserved.
 TERADATA CORPORATION CONFIDENTIAL AND TRADE SECRET 
 -->
<dscConfigAzureBlobStorage xmlns=\"http://schemas.teradata.com/v2012/DSC\">
	<config_azure_blob_storage>
		<!-- 'Storage account' - Required, max length 24, lower case -->
		<storage_account>${StorageAccount}</storage_account>
		<storage_type>cool</storage_type>
			<blobs>
				<!-- 'Blob container name' - Required, max length 63, lower case, at least one -->">>Config_Azure.xml

i=${NumberOfNodes}
for ((number=1;number <= i;number++))
{
	BlobContainerName="${BloboContainerPrefix}"$number
	PrefixName="${BlobPrefixNamePrefix}"$number

echo "				<blob_container>${BlobContainerName}</blob_container>
				<prefix_list>
					<!-- 'Prefix name' - Required, max length 256, at least one -->
					<prefix_name>${PrefixName}</prefix_name>
					<storage_devices>${StorageDevices}</storage_devices>
				</prefix_list>
			</blobs>">>Config_Azure.xml
}

echo "	</config_azure_blob_storage>
</dscConfigAzureBlobStorage>">>Config_Azure.xml