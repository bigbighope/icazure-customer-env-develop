#!/bin/bash

source parameters.sh

echo "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>
<dscConfigTargetGroupsAzureBlobStorage xmlns=\"http://schemas.teradata.com/v2012/DSC\">
	<!-- 'target_group_name' - Required, max characters 30	-->
	<target_group_name>${TargetGgroupName}</target_group_name>
	<is_enabled>true</is_enabled>
	<storage_account>${StoracgeAccount}</storage_account>
	<storage_type>cool</storage_type>">> Config_TargetGroups_Azure.xml

i=${NumberOfNodes}
for ((number=1;number <= i;number++))
{
	BlobContainerName="${BloboContainerPrefix}"$number
	PrefixName="${BlobPrefixNamePrefix}"$number
	BarMediaServer="node"$number"_media"

echo "	<targetMediaBlob>
		<bar_media_server>${BarMediaServer}</bar_media_server>
		<blobs>
		   <blob_container>${BlobContainerName}</blob_container>
			<prefix_list>
				<prefix_name>${PrefixName}</prefix_name>
				<storage_devices>${StorageDevices}</storage_devices>
			</prefix_list>
		</blobs>
	</targetMediaBlob>">> Config_TargetGroups_Azure.xml
}

echo "</dscConfigTargetGroupsAzureBlobStorage>" >> Config_TargetGroups_Azure.xml

