#!/bin/bash

version_dir="staging"

declare -a file_list=$(ls -l $version_dir/ | sed 1d | awk -F" " '{print $9}' | awk -F"." '{print $1}' | sort | uniq)
#declare -a channel_list=("alpha" "beta" "stable")
declare -a channel_list=$(ls -l $version_dir/ | sed 1d | awk -F" " '{print $9}' | awk -F"." '{print $2}' | sort | uniq)

for file_name in ${file_list[@]}
do
    for channel_name in ${channel_list[@]}
    do
        default_file_name="$version_dir/$file_name.$channel_name.default"
        versions_file_name="$version_dir/$file_name.$channel_name.versions"

        default_version=$(cat $default_file_name)

        grep -w "$default_version" $versions_file_name
        if [ "$?" = "0" ]
        then
            echo "version found for file: $file_name.$channel_name.default"
        else
            echo "version not found for file: $file_name.$channel_name.default"
        fi
    done
done
