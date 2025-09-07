#! /usr/bin/env bash
################################################################################
# encrypt.sh                                                                   #
################################################################################
#
# Encrypt files with a set of gpg public keys
#
# The set of gpg public keys (recipients) is currently hardcoded in this script.
#
# If given no arguments, all files except *.{gpg,sh} will be encrypted
# to the standard set of recipients.
# If given an argument, that file will be encrypted to the standard set
# of recipients.
#

# Quick test to see if this script is being sourced
# https://stackoverflow.com/a/28776166/2184226
(return 0 2>/dev/null) && sourced=1 || sourced=0

if [[ $sourced -eq 1 ]]
then
    echo "This script must not be sourced!"
    return 1
fi

################################################################################
# Constants                                                                    #
################################################################################

# parameters for formatting the output to the console
# use like this: echo "Note: ${RED}Highlight this important${RESET} thing."
RESET=`tput -Txterm sgr0`
BOLD=`tput -Txterm bold`
BLACK=`tput -Txterm setaf 0`
RED=`tput -Txterm setaf 1`
GREEN=`tput -Txterm setaf 2`
YELLOW=`tput -Txterm setaf 3`
BLUE=`tput -Txterm setaf 4`
MAGENTA=`tput -Txterm setaf 5`
CYAN=`tput -Txterm setaf 6`
WHITE=`tput -Txterm setaf 7`

################################################################################
# Command Options and Arguments                                                #
################################################################################
# Initialized to default values
# boolean values (0,1) should be tested using (( ))
GLOB='*'
declare -a RECIPIENTS=(
        mlippert255@gmail.com\
    )


################################################################################
# Help                                                                         #
################################################################################
Help()
{
    # Display Help
    echo "Encrypt files with a set of gpg public keys"
    echo
    echo "${BOLD}Note:${RESET} Already encypted files (a matching *.gpg file exists) and script files ((*.sh)"
    echo "      will not be encrypted. To re-encrypt a file, delete the matching *.gpg file."
    echo
    echo "Syntax: $0 [-h] [<filename>...]"
    echo "options:"
    echo "h     Print this Help."
}

################################################################################
# ParseOptions                                                                 #
################################################################################
ParseOptions()
{
    local OPTIND

    while getopts ":h" option; do
        case $option in
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

    # set the OPTION_ARG_CNT so the caller can shift away the processed options
    # shift $OPTION_ARG_CNT
    let OPTION_ARG_CNT=OPTIND-1
}
################################################################################
################################################################################
# Process the input options, validate arguments.                               #
################################################################################
ParseOptions "$@"
shift $OPTION_ARG_CNT

# Test validity of and set required arguments

# All arguments s/b files to encrypt. If none are specified the GLOB will remain
# set to * (all files in the directory)
if [ $# -gt 0 ]
  then
    GLOB=$@
fi


################################################################################
################################################################################
# Main program                                                                 #
################################################################################
################################################################################

# Turn the recipient array into a recipient options string
for r in ${RECIPIENTS[*]}; do R_OPTS="${R_OPTS} -r ${r}"; done

for f in $GLOB
do
    [ -e $f ] || (echo "$f is not a file"; continue)
    [[ $f == *.gpg || $f == *.sh ]] && { echo "ignoring $f"; continue; }
    [[ -f $f.gpg ]] && { echo "already encrypted, delete $f.gpg to encrypt again"; continue; }
    echo -n encrypting $f ...
    gpg --encrypt --sign ${R_OPTS} --output $f.gpg $f
    echo done
done
