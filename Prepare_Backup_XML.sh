#!/bin/bash

source parameters.sh

echo "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>
<dscCreateJob xmlns=\"http://schemas.teradata.com/v2012/DSC\">
    <job_instance>
        <job_name>${BackupJobName}</job_name>
        <job_description>Taking backup of \"TEST_DB\" database</job_description>
        <job_type>BACKUP</job_type>
        <job_state>ACTIVE</job_state>
        <auto_retire>false</auto_retire>
        <objectlist>
            <objectinfo>
                <object_name>TEST_DB</object_name>
                <object_type>DATABASE</object_type>
                <parent_name>DBC</parent_name>
                <parent_type>DATABASE</parent_type>
                <object_attribute_list>
                    <includeAll>false</includeAll>
                </object_attribute_list>
            </objectinfo>
        </objectlist>
    </job_instance>
    <source_tdpid>${SystemName}</source_tdpid>
    <target_media>${TargetGgroupName}</target_media>
    <job_options>
        <online>false</online>
        <data_phase>DATA</data_phase>
        <query_band></query_band>
        <dsmain_logging_level>Error</dsmain_logging_level>
        <nowait>true</nowait>
        <skip_archive>false</skip_archive>
    </job_options>
</dscCreateJob>" >> ${BackupJobName}.xml

