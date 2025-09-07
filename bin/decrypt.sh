#! /usr/bin/env bash
################################################################################
# script-template.sh                                                           #
################################################################################
#
# Decrypt a file encrypted with gpg with a private key in your keyring.
#
# It defines 2 ways to parse options, one, getopts, is builtin to bash so it
# should always be available, but it only supports short options.
# The other uses getopt, which supports long (--prefix) and short options, but
# it might not be available on all systems.
#
# The template also has some example snippets for testing if the script is
# being sourced, for testing the number of postional parameters, and for
# testing if it is being run as root.
#
# You can test this script:
#  script-template-mjl.sh -v --test=file1 one "two (2)" three
#

# Quick test to see if this script is being sourced
# https://stackoverflow.com/a/28776166/2184226
(return 0 2>/dev/null) && sourced=1 || sourced=0

if [[ $sourced -eq 1 ]]
then
    echo "This script must not be sourced!"
    return 1
fi

# In an executed script, restore the current directory to what it was when the script was called
# from: https://emmer.dev/blog/resetting-the-working-directory-on-shell-script-exit/
trap "cd \"${PWD}\"" EXIT

################################################################################
# Constants                                                                    #
################################################################################

# Define variables that are not dependent on options or positional parameters here
# such as the example DATE_TODAY, or values that you only want to change by editing
# the script, but they are used in multiple places.
# I've included some that are useful for formatting output. I'd always keep these
# so you don't have to find them when you're updating the script later and want
# to use different ones.

DATE_TODAY=$(date +%F)

if hash tput 2>/dev/null; then
    # parameters for formatting the output to the console
    # use like this: echo "Note: ${RED}Highlight this important${RESET} thing."
    RESET=`tput -Txterm sgr0`
    BOLD=`tput -Txterm bold`
    DIM=`tput -Txterm dim`
    BLACK=`tput -Txterm setaf 0`
    RED=`tput -Txterm setaf 1`
    GREEN=`tput -Txterm setaf 2`
    YELLOW=`tput -Txterm setaf 3`
    BLUE=`tput -Txterm setaf 4`
    MAGENTA=`tput -Txterm setaf 5`
    CYAN=`tput -Txterm setaf 6`
    WHITE=`tput -Txterm setaf 7`
fi

################################################################################
# Command Options and Arguments                                                #
################################################################################
# Initialized to default values
# boolean values (0,1) should be tested using (( ))
#   i.e. bval=1; if ((bval)); then echo true; else echo false; fi # true
VERBOSE=0
F_IN=
F_OUT=

################################################################################
# Help                                                                         #
################################################################################
Help()
{
    # Display Help
    echo "Decrypt a file encrypted with gpg with a private key in your keyring."
    echo
    echo "Syntax: $0 [-h] [-o <decrypted-filename>] <encrypted-filename>"
    echo "options:"
    echo "-o,--output   The filename where the decrypted input file will be (over)written."
    echo "              If not specified the output file will be the input file with a .gpg"
    echo "              extension removed. If that file exists or the input file doesn't have"
    echo "              a .gpg extension the decryption will be aborted with an error."
    echo "-h,--help     Print this Help."
}

################################################################################
# ParseOptions uses getopts to parse options, only handles short options       #
################################################################################
ParseOptions()
{
    local OPTIND

    while getopts ":ho:" option; do
        case $option in
            o) # The output file to write the decrypted file into (will be overwritten if it exists)
                F_OUT=${OPTARG}
                ;;
            v) # Turn on verbose output
                VERBOSE=1
                ;;
            h) # display Help
                Help
                exit -1
                ;;
            \?) # incorrect option
                echo "Error: Invalid option. Use -h for help."
                exit -1
                ;;
        esac
    done

    # shift off all options and option arguments
    shift $((OPTIND-1))

    # set the POSITIONAL_ARGS so the caller can process them
    # either directly or putting them back in $1... via eval set -- "$POSITIONAL_ARGS"
    POSITIONAL_ARGS=
    for arg in "$@"; do POSITIONAL_ARGS="$POSITIONAL_ARGS '$arg'"; done
}

################################################################################
# ParseOptionsExt uses getopt instead of getopts, so it can handle long options#
################################################################################
ParseOptionsExt()
{
    local LONG_OPTIONS=help,output:
    local SHORT_OPTIONS=ho:

    local CMDNAME="$0"

    local PARSED_ARGUMENTS # make local first so it doesn't override the getopt return code
    PARSED_ARGUMENTS=$(getopt --name=$CMDNAME --options=$SHORT_OPTIONS --long=$LONG_OPTIONS -- "$@")
    local GETOPT_ERROR=$?

    echo " getopt error code: $GETOPT_ERROR"
    if ((GETOPT_ERROR)); then
        echo "${RED}ERROR:${RESET} Invalid options found in commandline: $@"
        echo
        Help
        exit -1
    fi

    eval set -- "$PARSED_ARGUMENTS"
    while :; do
        case "$1" in
            -v | --verbose)     VERBOSE=1     ; shift   ;;
            -o | --output)      F_OUT="$2"    ; shift 2 ;;
            -h | --help)                        shift
                Help
                exit -1
                ;;
            # -- means the end of the arguments; drop this, and break out of the while loop
            --)                                 shift   ; break ;;

            # This should not happen because it should have been caught when getopt parsed
            # the cmdline as a non-zero VALID_ARGUMENTS
            *)
                echo "${RED}ERROR:${RESET} Unexpected option: $1 - this should not happen."
                echo
                Help
                exit -1
                ;;
        esac
    done

    # set the POSITIONAL_ARGS so the caller can process them
    # either directly or putting them back in $1... via eval set -- "${POSITIONAL_ARGS[@]"
    #   DEVNOTE: this will break if the args contain single quotes, it is rare
    #            enough that I'm not going to address it now.
    POSITIONAL_ARGS=
    for arg in "$@"; do POSITIONAL_ARGS="$POSITIONAL_ARGS '$arg'"; done
}

################################################################################
################################################################################
# Process the input options, validate arguments.                               #
################################################################################
ParseOptionsExt "$@"
eval set -- "$POSITIONAL_ARGS"

# Test validity of and set required arguments

if [ $# -ne 1 ]; then
    echo "${RED}ERROR:${RESET} ${BOLD}One argument is required.${RESET}"
    echo
    Help
    exit -1
fi

# Should not be run as root
if [ "$EUID" -eq 0 ]; then
    echo "${RED}ERROR:${RESET} ${BOLD}Must not be run as root.${RESET}"
    echo
    Help
    exit -1
fi

F_IN=$1
shift 1
ARG_REST=$@

# If no output file is specified, check the input file for a gpg extension
# remove it to determine the output filename and test that that file does NOT
# exist.
if [[ -z "$F_OUT" ]]; then
    if [[ "$F_IN" != *.gpg ]]; then
        echo "${RED}ERROR:${RESET} ${BOLD}No output file specified AND the input file does not have a .gpg extension.${RESET}"
        exit -1;
    fi

    F_OUT=${F_IN%.gpg}

    # Don't have to do this as the gpg decrypt will ask before overwriting an output file
    # and if the answer is no, it will ask for a new output filename
    #if [ -f "$F_OUT" ]; then
    #    echo "${RED}ERROR:${RESET} ${BOLD}Output file derived from input file exists, delete '$F_OUT' and try again.${RESET}"
    #    exit -1;
    #fi
fi

################################################################################
################################################################################
# Main program                                                                 #
################################################################################
################################################################################

#if ((VERBOSE)); then echo "VERBOSE is true"; else echo "VERBOSE is false"; fi

# Work in Progress....
echo "${BOLD}Decrypting $F_IN into $F_OUT ...${RESET}"
gpg --decrypt --output $F_OUT $F_IN
