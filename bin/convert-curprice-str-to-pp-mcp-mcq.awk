#!/usr/bin/env -S awk -f

# convert-curprice-str-to-pp-mcp-mcq.awk
#
# Execute by:
# if executable:
# ./convert-curprice-str-to-pp-mcp-mcq.awk input_csvfile
# else:
# awk -f convert-curprice-str-to-pp-mcp-mcq.awk input_csvfile
#
# Strip out all '$' because they're extraneous and only present some of the time
# if the first character is not a digit, assume it can't be parsed and leave the 3 field empty
# else
# if '/' is not present assume text is for just the PP value, this should handle all case's
#   price over 999 as I don't believe any of those have a multi case price discount
# else
# split the text on the ',', the 1st part is the PP value
# split the 2nd part on the '/', the 1st part is the multi case price, the 2nd the multi case quantity

BEGIN {
    FS = "\t"
    OFS = FS

    # Name the fields
    WineId = 1
    AccountingItemNo = 2
    NY_CurrentPricing = 3
    NY_PP = 4
    NY_MultiCasePrice = 5
    NY_MultiCaseQty = 6
    NJ_CurrentPricing = 7
    NJ_PP = 8
    NJ_MultiCasePrice = 9
    NJ_MultiCaseQty = 10
}

{
    ParseFreeFormPriceString(NY_CurrentPricing, NY_PP, NY_MultiCasePrice, NY_MultiCaseQty)
    ParseFreeFormPriceString(NJ_CurrentPricing, NJ_PP, NJ_MultiCasePrice, NJ_MultiCaseQty)
    print $0
}

function ParseFreeFormPriceString(CurPriceFld, PPFld, MCPriceFld, MCQtyFld)
{
    ffcurprice = $CurPriceFld

    # strip all '$'s
    gsub(/\$/, "", ffcurprice)

    # only parse if 1st char is a number
    if(ffcurprice ~ /^[0-9]/) {
        if(ffcurprice !~ /,.+\//) {
            # no multi case price/qty, strip commas then set only PP field
            gsub(/,/, "", ffcurprice)
            $PPFld = ffcurprice + 0
        }
        else {
            # multi case price/qty exists in ffcurprice
            # NOTE: This will have issues for any ffprice that has a comma thousands separator
            # It looks like perhaps always the separator is comma space?!, so lets try that.
            split(ffcurprice, prices, /, /)
            gsub(/,/, "", prices[1])
            $PPFld = prices[1] + 0

            split(prices[2], multicase, "/")
            gsub(/,/, "", multicase[1])
            $MCPriceFld = multicase[1] + 0
            $MCQtyFld = multicase[2] + 0
        }
    }
}
