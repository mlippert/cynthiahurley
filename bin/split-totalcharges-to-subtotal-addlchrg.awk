#!/usr/bin/env -S awk -f

# split-totalcharges-to-subtotal-addlchrg.awk
#
# Execute by:
# if executable:
# ./split-totalcharges-to-subtotal-addlchrg.awk input_csvfile
# else:
# awk -f split-totalcharges-to-subtotal-addlchrg.awk input_csvfile
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
    EmailOrderId = 1
    FirstDate = 2
    FullName = 3
    Email1 = 4
    TotalRetailCharge = 5
    Subtotal = 6
    AdditionalCharges = 7
}

{
    totalCharge = $TotalRetailCharge

    addlChargesIndex = index(totalCharge, " ") + 1

    if(addlChargesIndex == 1) {
        SetSubtotal(totalCharge)
    }
    else {
        SetSubtotal(substr(totalCharge, 1, addlChargesIndex - 2))
        SetAdditionalCharges(substr(totalCharge, addlChargesIndex))
    }

    print $0
}

function SetSubtotal(rawSubtotal)
{
    # strip all non digit & decimal point characters
    gsub(/[^0-9.]/, "", rawSubtotal)

    if(length(rawSubtotal) != 0) $Subtotal = rawSubtotal + 0
}

function SetAdditionalCharges(rawAdditionalCharges)
{
    $AdditionalCharges = rawAdditionalCharges
}
