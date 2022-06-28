#!/bin/bash

version_checker() {
    echo "Call the function for version directory: $1"

    version_dir="$1"

    # Get the file list from the version directory
    declare -a file_list=$(ls -l $version_dir/ | sed 1d | awk -F" " '{print $9}' | awk -F"." '{print $1}' | sort | uniq)

    # Get the channel list from the files
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
                echo "Version: [$default_version] found in file: $versions_file_name"
            else
                echo "Version: [$default_version] not found in file: $versions_file_name"
                exit 1
            fi
        done
    done

}

# Call version_checker function for staging directory
version_checker "staging"

# Call version_checker function for production directory
version_checker "production"