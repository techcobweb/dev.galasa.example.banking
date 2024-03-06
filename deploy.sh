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
    info "Syntax: deploy.sh [OPTIONS]"
    cat << EOF
Options are:
--bootstrap : Optional. A URL to the bootstrap endpoing on the Galasa Ecosystem.
  If not specified, the value will be drawn from the GALASA_BOOTSTRAP environment variable.
  For example:
    https://galasa-ecosystem1.galasa.dev/api/bootstrap

--token : Optional. A token provided by the Web UI as a proxy for credentials for a person.
  If not specified, the value will be drawn from the GALASA_TOKEN environment variable.
  For example:
    ChlyZHVuZ2GdxxxxxYyyyYyYy123456789khjqweiasc:hopta821hkjahsd2n45x4vwn

--stream : Optional. Which stream on the server should the test catalog be published to ?
  If not specified, the value will be drawn from the GALASA_STREAM environment variable.
  For example:
    inttests

Environment variables:
GALASA_BOOSTRAP : optional. Over-ridden by the --bootstrap option. 
    The script needs a value for this, so either the environment variable or the option must be specified.

GALASA_STREAM : optional. Over-ridden by the --stream option.
    The script needs a value for this, so either the environment variable or the option must be specified.

GALASA_TOKEN : optional. Over-ridden by the --token option.
    The script needs a value for this, so either the environment variable or the option must be specified.

EOF
}

while [ "$1" != "" ]; do
    case $1 in
        -h | --help )           usage
                                exit
                                ;;
        --bootstrap )           export GALASA_BOOTSTRAP=$1
                                shift
                                ;;
        --token )               export GALASA_TOKEN=$1
                                shift
                                ;;
        --stream )              export GALASA_STREAM=$1
                                shift
                                ;;
        * )                     error "Unexpected argument $1"
                                usage
                                exit 1
    esac
    shift
done

#-----------------------------------------------------------------------------------------
function check_required_parameters_are_available {
    h1 "Checking that required parameters are available"

    export is_error="no-error"
    if [[ "$GALASA_BOOTSTRAP" == "" ]]; then 
        error "Environment variable GALASA_BOOTSTRAP is not set, and the '--bootstrap <URL>' option has not been used. One is mandatory."
        is_error="error"
    fi

    if [[ "$GALASA_TOKEN" == "" ]]; then 
        error "Environment variable GALASA_TOKEN is not set, and the '--token <value>' option has not been used. One is mandatory."
        is_error="error"
    fi

    if [[ "$GALASA_STREAM" == "" ]]; then
        error "Environment variable GALASA_STREAM is not set, and the '--stream <value>' option has not been used. One is mandatory."
        is_error="error"
    fi

    if [[ "$is_error" != "no-error" ]]; then
        exit 1
    fi
}

function publish_to_server {
    h1 "Publishing the test code to a Galasa ecosystem using maven"
    info "We publish the maven artifacts to a maven store, and push the test catalog artifact into the Galasa server."
    cmd="mvn deploy dev.galasa:galasa-maven-plugin:deploytestcat \
        -Dmaven.deploy.skip=true
        -DGALASA_TOKEN=$GALASA_TOKEN \
        -DGALASA_BOOTSTRAP=$GALASA_BOOTSTRAP \
        -DGALASA_STREAM=$GALASA_STREAM "
    info "Command is $cmd"
    $cmd
    rc=$? ; if [[ "${rc}" != "0" ]]; then error "Failed to publish the test catalog to the galasa ecosystem using maven. Return code: ${rc}" ; exit 1 ; fi
    success "OK"
}

check_required_parameters_are_available
publish_to_server 
