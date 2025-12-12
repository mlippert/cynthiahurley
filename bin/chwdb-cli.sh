#! /usr/bin/env bash
################################################################################
# chwdb-cli.sh                                                                 #
################################################################################
#
# Connect to an interactive mariadb/mysql cli on the running chw database in a container
#
# NOTE: To use the following query to write a csv file of the Users table records w/ Id, Username and Email
#   you may need to log in to mariadb/mysql as the root user (who should have FILE privilege)
#   and you have to write the output file to the /var/lib/mysql-files/ directory which
#   is specified by the --secure-file-priv option.
# SELECT Id, Username, Email FROM Users INTO OUTFILE '/var/lib/mysql-files/said-oxford-users.csv'
#   FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
#   LINES TERMINATED BY '\n';
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

# Command to run in the DB container for the database's CLI
DB_CLI=mariadb
#DB_CLI=mysql

# Container management command
CNTR_CLI=podman
#CNTR_CLI=docker

# Filters that could be used to get the name of a running DB container
# the one that will be used is assigned to DB_CNTR_FILTER
VOLUME_FILTER="volume=cynthiahurley_chw-mariadb-retailorders-data"
NAME_FILTER="name=chw-mariadb"
DB_CNTR_FILTER=$NAME_FILTER

DB_CNTR=$($CNTR_CLI ps --filter="$DB_CNTR_FILTER" --filter="status=running" --format={{.Names}})

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
DB_USER=chwuser
DB_PSWD=cynthiahurley
DB_NAME=chw
CNTR_CMD=$DB_CLI

VERBOSE=1
ARG_REST=

################################################################################
# Help                                                                         #
################################################################################
Help()
{
    # Display Help
    echo "Connect to an interactive mariadb/mysql cli on the running chw database in a container"
    echo
    echo "In general you should not have to specify any options as the defaults"
    echo "are set to use the correct user/pswd and database."
    echo
    echo "However, the default user/pswd can be overridden with the options in order"
    echo "to, for example, log in as the root user."
    echo "Or to invoke ${BOLD}bash${RESET} instead of the database cli in the container."
    echo
    echo "Syntax: $0 [-h] [-u <DB user>] [-p <user password>] [-c <Container command>] [-D <DB name>] [-v] <POS_ARG1> <POS_ARG2> [<OPTIONAL_ARG>...]"
    echo "options:"
    echo "-u,--user     Database user to sign in with. Defaults to '$DB_USER'"
    echo "-p,--password Password for the database user. Defaults to '$DB_PSWD'"
    echo "-c,--cmd      Command to run in the container. Defaults to '$DB_CLI'"
    echo "-D,--db       Name of database to 'use'. Defaults to '$DB_NAME'"
    echo "-v,--verbose  Verbose output, currently the default"
    echo "-q,--quiet    Turn off verbose output"
    echo "-h,--help     Print this Help."
}

################################################################################
# ParseOptionsExt uses getopt instead of getopts, so it can handle long options#
################################################################################
ParseOptionsExt()
{
    local LONG_OPTIONS=help,user:,password:,cmd:,db:,verbose,quiet
    local SHORT_OPTIONS=hu:p:c:D:vq

    local CMDNAME="$0"

    local PARSED_ARGUMENTS # make local first so it doesn't override the getopt return code
    PARSED_ARGUMENTS=$(getopt --name=$CMDNAME --options=$SHORT_OPTIONS --long=$LONG_OPTIONS -- "$@")
    local GETOPT_ERROR=$?

    # DEBUG: echo " getopt error code: $GETOPT_ERROR"
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
            -q | --quiet)       VERBOSE=0     ; shift   ;;
            -u | --user)        DB_USER="$2"  ; shift 2 ;;
            -p | --password)    DB_PSWD="$2"  ; shift 2 ;;
            -c | --cmd)         CNTR_CMD="$2" ; shift 2 ;;
            -D | --db)          DB_NAME="$2"  ; shift 2 ;;
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

# Must not be run as root
if [ "$EUID" -eq 0 ]; then
    echo "${RED}ERROR:${RESET} ${BOLD}Must not be run as root.${RESET}"
    echo
    Help
    exit -1
fi

CNTR_CMDARGS="--user=$DB_USER --password=$DB_PSWD $DB_NAME"
if [ "$CNTR_CMD" != "$DB_CLI" ]; then
    # The command arguments are only for the DB_CLI, so remove them
    CNTR_CMDARGS=
fi

ARG_REST=$@


################################################################################
################################################################################
# Main program                                                                 #
################################################################################
################################################################################

if ((VERBOSE)); then
    # NOTE: heredoc leading tabs ignored NOT leading spaces
    cat <<- EOF
	Here are some helpful example mariadb/mysql commands:
	SHOW databases;
	USE chw;
	DESCRIBE EmailCustomers;
	CREATE OR REPLACE TABLE LegacyWineMaster_1106 (WineId INT NOT NULL, ...);
	SELECT Username, Email, Props FROM Users WHERE Props NOT LIKE '{"lti%';
	UPDATE Users SET Props = '{}' WHERE Username = 'juliah_esme';

	EOF
fi

$CNTR_CLI exec -it "$DB_CNTR" $CNTR_CMD $CNTR_CMDARGS
