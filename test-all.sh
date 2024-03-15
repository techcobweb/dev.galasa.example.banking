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
    info "Syntax: test-all.sh [OPTIONS]"
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


# First, with maven
$BASEDIR/build-locally.sh --maven
rc=$? ; if [[ "$rc" != "0" ]]; then error "Failed to build with maven" ; exit 1 ; fi
$BASEDIR/deploy-to-ecosystem.sh --maven
rc=$? ; if [[ "$rc" != "0" ]]; then error "Failed to deploy with maven" ; exit 1 ; fi
$BASEDIR/run-locally.sh
rc=$? ; if [[ "$rc" != "0" ]]; then error "Failed to run with artifacts built using maven" ; exit 1 ; fi

# Now with gradle
$BASEDIR/build-locally.sh --gradle
rc=$? ; if [[ "$rc" != "0" ]]; then error "Failed to build with gradle" ; exit 1 ; fi
$BASEDIR/deploy-to-ecosystem.sh --gradle
rc=$? ; if [[ "$rc" != "0" ]]; then error "Failed to deploy with gradle" ; exit 1 ; fi
$BASEDIR/run-locally.sh
rc=$? ; if [[ "$rc" != "0" ]]; then error "Failed to run with artifacts built using gradle" ; exit 1 ; fi
