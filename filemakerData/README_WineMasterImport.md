CHW Notes for Importing the Legacy WineMaster table from FilemakerPro
=====================================================================

## Export the Master table to an Excel spreadsheet

1. Create a table layout (or update the existing `t.WineMaster-MJL`) with all of the columns from the
`Cynthia Hurley French Wines Product Database MASTER` table.

2. Uncheck the following columns so they don't appear in the layout:
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

- DateCreated
- LastPurchaseDate_PO
- EstArrival
- CT_BrandRegExpDate
- LastPurchase_AE_ImportDate
- LOA_Date
- StatesAuthConfirmationDate

Format these Timestamp columns:

- LastUpdated

### Export to csv

In LibreOffice Calc

- Select  File Save As...
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
