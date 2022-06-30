#!/bin/bash

echo "--------------------------------------------------------------------------"
echo "|    Script to verify and validate versions from the 128T artifactory    |"
echo "--------------------------------------------------------------------------"

# Verify if default version is available or not in respective versions files
version_checker() {
    echo "Function called for version directory: [$1]"

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
                    #exit 1
                fi
            else
                echo "File [${default_file_name}] is empty"
            fi
        done
    done

}

# Validate the default version on 128T artifactory
# https://software.128technology.com/api/search/artifact
# https://technology128t.jfrog.io/artifactory

version_validate() {
    echo "Function called for version directory: [$1]"

    version_dir="$1"

    # Get the file list from the version directory
    declare -a file_list=$(ls -l $version_dir/ | sed 1d | awk -F" " '{print $9}' | awk -F"." '{print $1}' | sort | uniq)

    # Get the channel list from the files
    declare -a channel_list=$(ls -l $version_dir/ | sed 1d | awk -F" " '{print $9}' | awk -F"." '{print $2}' | sort | uniq)

    artifact_url="https://software.128technology.com/api/search/artifact"

    for file_name in ${file_list[@]}
    do
        for channel_name in ${channel_list[@]}
        do
            default_file_name="$version_dir/$file_name.$channel_name.default"
            default_version=$(cat $default_file_name)
            pkg_extension="rpm"

            if [ $file_name == "128T" ]
            then
                prefix="rpm-128t" 
            elif [ $file_name == "128T-mist-agent" ]
            then
                prefix="rpm-cloud-edge"
            elif [ $file_name == "128T-wheeljack" ]
            then
                prefix="rpm-cloud-edge"
            elif [ $file_name == "128T-cloud-intel-agent" ]
            then
                prefix="rpm-cloud-edge"
            elif [ $file_name == "128T-ash" ]
            then
                prefix="rpm-cloud-edge"
            elif [ $file_name == "SSR" ]
            then
                prefix="generic-128t-install-images"
                pkg_extension="tar"
            fi

            if [ -s ${default_file_name} ]
            then    
                default_pkg_name=$file_name-$default_version.$pkg_extension

                if [ "$channel_name" == "stable" ]
                then
                    channel_name="release"
                fi

                artifact_urls="$artifact_url?name=$file_name&repos=$prefix-$channel_name-local"
                curl_cmd="curl -su $MIST_USER:$MIST_PASS "$artifact_urls""

                rpm_pkg_name=$($curl_cmd | jq -r '.results[].uri' | sort --version-sort | awk -F"/" '{print $NF}' | grep ".$pkg_extension$")

                echo -e "----------------------------------------------------------"
                echo $artifact_urls
                echo "  Default pkg name = ${default_pkg_name}"

                echo "$rpm_pkg_name" | grep "$default_pkg_name" &>/dev/null
                if [ "$?" -eq 0 ]
                then
                    echo -e "  Package found ---> $default_pkg_name"
                    echo -e "----------------------------------------------------------\n"
                else
                    echo -e "  ****************  Package not found  **************** "
                    echo -e "----------------------------------------------------------\n"
                    #exit 1
                fi
            fi
        done
    done

    # https://software.128technology.com/api/search/artifact?name=<pkg>&repos=<prefix>-<channel>-local
}

# Call version_validate function for staging directory
version_validate "staging"

# Call version_validate function for production directory
#version_validate "production"

# Call version_checker function for staging directory
version_checker "staging"

# Call version_checker function for production directory
#version_checker "production"
