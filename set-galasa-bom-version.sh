#! /usr/bin/env bash 

#
# Copyright contributors to the Galasa project
#
# SPDX-License-Identifier: EPL-2.0
#

#-----------------------------------------------------------------------------------------                   
#
# Objectives: Sets the version number of this component.
#
# Environment variable over-rides:
# None
# 
#-----------------------------------------------------------------------------------------                   

# Where is this script executing from ?
BASEDIR=$(dirname "$0");pushd $BASEDIR 2>&1 >> /dev/null ;BASEDIR=$(pwd);popd 2>&1 >> /dev/null
# echo "Running from directory ${BASEDIR}"
export ORIGINAL_DIR=$(pwd)
# cd "${BASEDIR}"

cd "${BASEDIR}/.."
WORKSPACE_DIR=$(pwd)


#-----------------------------------------------------------------------------------------                   
#
# Set Colors
#
#-----------------------------------------------------------------------------------------                   
bold=$(tput bold)
underline=$(tput sgr 0 1)
reset=$(tput sgr0)
red=$(tput setaf 1)
green=$(tput setaf 76)
white=$(tput setaf 7)
tan=$(tput setaf 202)
blue=$(tput setaf 25)

#-----------------------------------------------------------------------------------------                   
#
# Headers and Logging
#
#-----------------------------------------------------------------------------------------                   
underline() { printf "${underline}${bold}%s${reset}\n" "$@" ;}
h1() { printf "\n${underline}${bold}${blue}%s${reset}\n" "$@" ;}
h2() { printf "\n${underline}${bold}${white}%s${reset}\n" "$@" ;}
debug() { printf "${white}%s${reset}\n" "$@" ;}
info() { printf "${white}➜ %s${reset}\n" "$@" ;}
success() { printf "${green}✔ %s${reset}\n" "$@" ;}
error() { printf "${red}✖ %s${reset}\n" "$@" ;}
warn() { printf "${tan}➜ %s${reset}\n" "$@" ;}
bold() { printf "${bold}%s${reset}\n" "$@" ;}
note() { printf "\n${underline}${bold}${blue}Note:${reset} ${blue}%s${reset}\n" "$@" ;}

#-----------------------------------------------------------------------------------------                   
# Functions
#-----------------------------------------------------------------------------------------                   
function usage {
    h1 "Syntax"
    cat << EOF
set-galasa-bom-version.sh [OPTIONS]
Options are:
-v | --version xxx : Mandatory. Set the version number to something explicitly.
    For example '--version 0.33.0'
EOF
}

#-----------------------------------------------------------------------------------------                   
# Process parameters
#-----------------------------------------------------------------------------------------                   
component_version=""

while [ "$1" != "" ]; do
    case $1 in
        -v | --version )        shift
                                export component_version=$1
                                ;;
        -h | --help )           usage
                                exit
                                ;;
        * )                     error "Unexpected argument $1"
                                usage
                                exit 1
    esac
    shift
done

if [[ -z $component_version ]]; then 
    error "Missing mandatory '--version' argument."
    usage
    exit 1
fi



function update_pom_xml {
    source_file=$BASEDIR/pom.xml

    temp_dir=temp
    mkdir -p temp
    temp_file="temp/pom.xml.temp"

    set -o pipefail

    info "Updating file $source_file"
    # Note: There are several matches for <version>...</version> but the first one is the bom always.
    cat $source_file | sed "s/\<version>[.0-9]+\<\/version>/\<version>$component_version\<\/version>/1" > $temp_file
    rc=$?; if [[ "${rc}" != "0" ]]; then error "Failed to set the galasa bom version into $source_file file."; exit 1; fi
    cp $temp_file ${source_file}
    rc=$?; if [[ "${rc}" != "0" ]]; then error "Failed to overwrite new version of $source_file file."; exit 1; fi

    rm -f $temp_file
    success "$source_file updated OK."
}

function update_build_gradle {
    source_file=$1

    temp_dir=temp
    mkdir -p temp
    temp_file="temp/build.gradle.temp"

    set -o pipefail

    info "Updating file $source_file"
    cat $source_file | sed "s/implementation platform('dev.galasa:galasa-bom:.*')/\implementation platform('dev.galasa:galasa-bom:$component_version')/1" > $temp_file
    rc=$?; if [[ "${rc}" != "0" ]]; then error "Failed to set the galasa bom version into $source_file file."; exit 1; fi
    cp $temp_file ${source_file}
    rc=$?; if [[ "${rc}" != "0" ]]; then error "Failed to overwrite new version of $source_file file."; exit 1; fi

    rm -f $temp_file
    success "$source_file updated OK."
}

h2 "Updating the version of the galasa bom in the maven build files"
update_pom_xml 

h2 "Updating the version of the galasa bom in the gradle build files"
update_build_gradle ${BASEDIR}/dev.galasa.example.banking.account/build.gradle
update_build_gradle ${BASEDIR}/dev.galasa.example.banking.payee/build.gradle


