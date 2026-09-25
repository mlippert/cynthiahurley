CHW Notes for Importing the Legacy WineMaster table from FilemakerPro
=====================================================================

## Export the Master table to an Excel spreadsheet

**NOTE:** As of August 2026, I've given the WineMaster table a custom order, which is also the
order that the existing table layout, `t.WineMaster-MJL`, follows.

1. Create a table layout (or update the existing `t.WineMaster-MJL`) with all of the columns from the
`Cynthia Hurley French Wines Product Database MASTER` table.

2. Uncheck the following columns so they don't appear in the layout:
    - Boillot_Retail_DTC
    - Case Card
    - Shelf Talker
    - MA Bottle Price
    - OrganicLogoContainer
    - INCLUDE ON TASTING SHEET
    - Western_Inventory_Bottles
    - Western_Inventory_Cases
    - Stock Level for NY Boillot Sheet
    - WINEBOW Price
    - Winebow Special Price Identifier
    - Format
    - NY_Current_Calc
    - NYPP_Item#_Calc
    - Producer_Short_Name
    - Bttls_per_Case_and_size
    - Western_Inventory_Modified_Date

3. Make sure that the layout is showing ALL records
4. File menu | Save/Send Records As | Excel

## Edit the spreadsheet to export it to a CSV file

I prefer working with LibreOffice Calc, so I first open the .xlsx file in Calc and save it as an
ODF Spreadsheet (.ods)

Add 4 rows above the 1st header row, and 1 row below it.

Start by copying the contents of those rows from a previous exported spreadsheet

Also copy the formulas below each column that calculate the maximum number of characters
in the data in that column. Note that when you copy those formulas over, you will almost
definitely need to adjust the range in the formulas.

For some of the max character calculations the cell below calculates that number multiplied
by 1.25 in order to allow for multibyte UTF-8 characters in fields whose data may not be entirely
ASCII.

### New Columns

New columns will need to have their datatype determined and then be added to the
LegacyWineMaster table in the DBSchema file.

The suffix of that schema table name should be adjusted to reflect the date the data was
exported. Although if there are no new fields, that is unnecessary.

In addition the SQL statement in the variable `_legacy_wine_master_load_data_sql_fmt`
for importing the CSV file in the python file chwdata/chw_sql.py will need to be updated.

### Format the Date & Timestamp columns

In order to correctly interpret the dates and timestamps they should be changed to a
recognizable format, and I've found that for Dates YYYY-MM-DD (which is ISO 8601) and
for Timestamps YYYY-MM-DD"T"HH:MM:SS (which is ISO 8601)

Format these Date columns:

- LOA_Date
- StatesAuthConfirmationDate
- CT_BrandRegExpDate
- LastPurchaseDate_PO
- LastPurchase_AE_ImportDate
- EstArrival
    - fix wineId 3010 which is a string
- DateCreated

Format these Timestamp columns:

- WesternInventory_SyncTimestamp
- WesternInventory_UpdatedTimestamp
- LastUpdated

### Export to csv

In LibreOffice Calc

- Select Save a Copy...
- Change the Filter field to: `Text CSV (.csv)`
- Check `Edit filter settings` in order to get then next dialog after clicking Save to set Field Options
    - Character set: UTF-8
    - Field delimiter: |
    - String delimiter: "
    - Check Save cell content as shown

### Edit and Transform the saved csv to prepare for Loading into the table

Delete all the lines above the target column names line
Delete the last 5 lines of the file: 2 empty rows, 1 description row, then 2 rows w/ the max char calculations

#### Run the transform-for-infile.awk script

It does the following:

- Convert newlines within a column to \n so every record is on a single line

Example command:

```sh
gawk -f ../bin/transform-for-infile.awk WineMasterTable_08-06.csv > WineMasterTable_08-06-xform.csv
```

## Create a MariaDB database for importing the legacy table and normalizing it

### Replace chw database with clean database

If you have an existing chw database and you want to wipe it out and start fresh here's how:

The SQL command [SHOW CREATE DATABASE](https://mariadb.com/docs/server/reference/sql-statements/administrative-sql-statements/show/show-create-database)
will show you the command to create the named database with any special options.
Currently there aren't any special options.

```console
$ make up
$ bin/chwdb-cli.sh
MariaDB [chw]> SHOW CREATE DATABASE chw;
MariaDB [chw]> DROP DATABASE chw;
MariaDB [chw]> CREATE DATABASE chw;
MariaDB [chw]> exit
$
```

### Setting up an empty chw mariadb database
**These instructions are still a WIP**

The Makefile has targets for bringing up a Mariadb container (by default using podman).
The docker-compose.yml file specifies binding to directories in `data/mariadb` and `data/infiles`.
The Makefile has a target `setup-use-data-infiles` that will configure the chwuser to be allowed
to read and write from the `data/infiles` directory.

The python code in pysrc provides a CLI that had commands to work on the mariadb database. You run
commands using .`/chw-action`, you can see help using `./chw-action --help`

There is also a script that makes it easy to start the mariadb cli inside the running container
`bin/chwdb-cli.sh`. Currently you need to run this and then execute SQL commands found in
`CHW_Wine-only-MySQL-DDL.sql` to create the tables defined in the schema.

**NOTE**: While under development I've found it better to NOT create the FOREIGN KEY constraints
that are in the DDL script.

**NOTE**: Currently there are 3 CHECK constraints that are not in the DDL file that enforce values
in some columns. The SQL defining these constraints is in the snippets file: `snippets_WineMaster-tables.sql`.

Once those tables are created, you can exit the mariadb cli and use `./chw-action` to load the
csv file from `data/infiles` and also to populate the Lookup tables.

#### Import the legacy CSV file into LegacyWineMaster table

This command will load the `{datadir}{csvfile}` file into the mariaDB table `LegacyWineMaster{suffix}`

Remember that when a new csv is used and/or the columns in/name of the LegacyWineMaster table changes
the values of {csvfile} and {suffix} come from `class Wines` constants defined in `pysrc/chwdata/wines.py`.

i.e. `{datadir}{csvfile}` might resolve to `{datadir}{csvfile}` `data/infiles/WineMasterTable_08-24-xform.csv`.
     and `LegacyWineMaster{suffix}` might resolve to `LegacyWineMaster_0824`

```console
$ ./chw-action load-legacy-wine-master-from-csv
Load Data successful, 2154 rows affected, 316 warnings (0.000 secs)
Connection closed.
$
```

##### examples of possible errors
_Incorrect datetime value: '08/18/2026 16:49:13' for column \`chw\`.\`LegacyWineMaster_0824\`.\`LastUpdated\` at row 1_  
Date and Timestamp columns must be formatted as ISO 8601 'YYYY-MM-DD' and 'YYYY-MM-DD"T"HH:MM:SS'

_Incorrect date value: 'May 25, 2026' for column `chw`.`LegacyWineMaster_0824`.`EstArrival` at row 1992_  
Check that Date column data contains dates not strings

#### Populate the wine lookup tables

Populate the following lookup tables (should be all of them):

- LookupWineColors
- LookupWineTypes
- LookupCaseUnits
- LookupWineCountries
- LookupWineRegions
- LookupWineSubregions
- LookupWineAppellations
- LookupUSStates

Run this command from the cynthiahurley repository root directory:

```sh
./chw-action setup-wine-lookup-tables
```

#### Create producer records from the data in the legacy wine master table

Currently this is done by creating a producer by grouping the wine master records
by `ProducerName`, in ascending order by `LastUpdated`. The other producer fields,
`ProducerCode`, `ProducerDescription`, `YearEstablished` will be taken from the
_last_, ie latest, wine master record for that producer name.

A record associated the created producer record with each matching legacy wine record
is created in `Producers_LegacyWineMaster`. This table also has a column for conversion
notes. The conversion notes capture when the other column values changed from the previous
wine master record, and also if the year established represented a decade rather than a year.

Run this command from the cynthiahurley repository root directory:

```sh
./chw-action import-legacy-producers
```

#### Create wine records AND wine item records from the data in the legacy wine master table

The lookup tables should be populated and producer records created before running this step.

Identifying unique wines from the legacy wine master is done by...
- A WineCode identifies a unique wine.
- For wines without a WineCode...

Run this command from the cynthiahurley repository root directory:

```sh
./chw-action create-wines-from-legacy
```
