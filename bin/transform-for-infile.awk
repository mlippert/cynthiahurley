#!/usr/bin/env -S awk -f

# transform-for-infile.awk
#
# Execute by:
# if executable:
# ./transform-for-infile.awk input_csvfile
# else:
# awk -f transform-for-infile.awk input_csvfile
#
# Transform a "csv" file written by LibreOffice Calc
#   Save As: Text CSV (.csv)
#   with the filter options:
#     Field Delimiter: |
#     String Delimiter: "
#     Quote all text fields: checked
#
# into a form it can be read into a MariaDB table using the SQL statement:
#   LOAD DATA LOCAL INFILE '<Path To Transformed csv file'
#   REPLACE INTO TABLE <Destination Table Name>
#   FIELDS TERMINATED BY '|' OPTIONALLY ENCLOSED BY '"'
#   IGNORE 1 LINES
#   ( <Fields...> );
#
# Transformations:
# - Convert newlines in fields into backslash n ('\n')

/^[0-9]{4}\|/ { if ( record != "" ) print record; record = $0; next }
{ record = record "\\n" $0 }
END { if ( record != "" ) print record }
