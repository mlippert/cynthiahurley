#! /usr/bin/env bash
# Connect to an interactive mariadb/mysql cli on the running chw database in a container

# NOTE: To use the following query to write a csv file of the Users table records w/ Id, Username and Email
#   you may need to log in to mysql as the root user (who should have FILE privilege)
#   and you have to write the output file to the /var/lib/mysql-files/ directory which
#   is specified by the --secure-file-priv option.
# SELECT Id, Username, Email FROM Users INTO OUTFILE '/var/lib/mysql-files/said-oxford-users.csv'
#   FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
#   LINES TERMINATED BY '\n';

DB_USER=chwuser
DB_PSWD=cynthiahurley

DB_CLI=mariadb
#DB_CLI=mysql
CNTR_CLI=podman
#CNTR_CLI=docker

VOLUME_FILTER="volume=cynthiahurley_chw-mariadb-retailorders-data"
NAME_FILTER="name=chw-mariadb"
DB_CNTR_FILTER=$NAME_FILTER

DB_CNTR=$($CNTR_CLI ps --filter="$DB_CNTR_FILTER" --filter="status=running" --format={{.Names}})

cat << EOF
Here are some helpful example mariadb/mysql commands:
SHOW databases;
USE chw;
DESCRIBE EmailCustomers;
SELECT Username, Email, Props FROM Users WHERE Props NOT LIKE '{"lti%';
UPDATE Users SET Props = '{}' WHERE Username = 'juliah_esme';

EOF

$CNTR_CLI exec -it "$DB_CNTR" $DB_CLI --user=$DB_USER --password=$DB_PSWD
