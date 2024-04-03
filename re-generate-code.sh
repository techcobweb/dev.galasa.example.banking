#!/usr/bin/env bash

#
# Copyright contributors to the Galasa project
#
# SPDX-License-Identifier: EPL-2.0
#

# Where is this script executing from ?
BASEDIR=$(dirname "$0");pushd $BASEDIR 2>&1 >> /dev/null ;BASEDIR=$(pwd);popd 2>&1 >> /dev/null
# echo "Running from directory ${BASEDIR}"
export ORIGINAL_DIR=$(pwd)
cd "${BASEDIR}"


#--------------------------------------------------------------------------
#
# Set Colors
#
#--------------------------------------------------------------------------
bold=$(tput bold)
underline=$(tput sgr 0 1)
reset=$(tput sgr0)

red=$(tput setaf 1)
green=$(tput setaf 76)
white=$(tput setaf 7)
tan=$(tput setaf 202)
blue=$(tput setaf 25)

#--------------------------------------------------------------------------
#
# Headers and Logging
#
#--------------------------------------------------------------------------
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

#-----------------------------------------------------------------------------------------
function usage {
    info "Syntax: re-generate-code.sh [OPTIONS]"
    info "Re-generates the code in this project."
    cat << EOF
Options are:
<No options>
EOF
}


while [ "$1" != "" ]; do
    case $1 in
        -h | --help )           usage
                                exit
                                ;;
        * )                     error "Unexpected argument $1"
                                usage
                                exit 1
    esac
    shift
done


#-----------------------------------------------------------------------------------------
function re_gen_code {
    h1 "Re-generating the code in this project..."
    cd $BASEDIR/..

    # Add the "--log -" flag if you want to see more detailed output.
    cmd="galasactl project create --package dev.galasa.example.banking --features account,payee --obr --maven --gradle --development --force --log -"
    $cmd
    rc=$? ; if [[ "${rc}" != "0" ]]; then error "Failed to re-generate the source code. Return code: ${rc}" ; exit 1 ; fi
    success "OK"
}


function do_not_skip_testcatalog_deploy {
    h1 "Zapping the test catalog deploy property to be true in pom.xml"
    mkdir -p $BASEDIR/temp
    cat $BASEDIR/pom.xml | sed "s/galasa.skip.deploytestcatalog>true/galasa.skip.deploytestcatalog>false/g" > $BASEDIR/temp/pom.xml.temp
    cp $BASEDIR/temp/pom.xml.temp $BASEDIR/pom.xml
}

re_gen_code
do_not_skip_testcatalog_deploy
