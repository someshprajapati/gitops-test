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

            if [ -s ${default_file_name} ]
            then           
                grep -w "$default_version" $versions_file_name
                if [ "$?" = "0" ]
                then
                    echo "Version: [$default_version] found in file: $versions_file_name"
                else
                    echo "Version: [$default_version] not found in file: $versions_file_name"
                    exit 1
                fi
            else
                echo "File [${default_file_name}] is empty"
            fi
        done
    done

}

# Call version_checker function
version_checker "staging"

# Call version_checker function for production directory
version_checker "production"

version_validate() {
    echo "Version validation called"
    curl -su $MIST_USER:$MIST_PASS "https://software.128technology.com//api/search/artifact?name=128T&repos=rpm-cloud-edge-beta-local" | jq -r '.results[].uri' | sort --version-sort | grep "1.0.3222-1.el7.x86_64"
}

version_validate