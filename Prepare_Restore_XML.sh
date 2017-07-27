#!/bin/bash

source parameters.sh

echo "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>
<dscCreateJob xmlns=\"http://schemas.teradata.com/v2012/DSC\">
    <job_instance>
        <job_name>RES_DB_TEST_DB</job_name>
        <job_description></job_description>
        <job_type>RESTORE</job_type>
        <job_state>ACTIVE</job_state>
        <auto_retire>false</auto_retire>
        <backup_name>BKP_DB_TEST_DB</backup_name>
        <backup_version>0</backup_version>
        <all_backup_objects>true</all_backup_objects>
    </job_instance>
    <source_media>TG_01</source_media>
    <target_tdpid>${SystemName}</target_tdpid>
    <job_options>
        <enable_temperature_override>false</enable_temperature_override>
        <temperature_override>DEFAULT</temperature_override>
        <block_level_compression>DEFAULT</block_level_compression>
        <disable_fallback>false</disable_fallback>
        <query_band></query_band>
        <dsmain_logging_level>Error</dsmain_logging_level>
        <nowait>true</nowait>
        <reblock>false</reblock>
        <run_as_copy>false</run_as_copy>
        <skip_archive>false</skip_archive>
    </job_options>
</dscCreateJob>">>RES_DB_TEST_DB.xml


