#!/usr/bin/env -S awk -f

# split-totalcharges-to-subtotal-addlchrg.awk
#
# Execute by:
# if executable:
# ./split-totalcharges-to-subtotal-addlchrg.awk input_csvfile
# else:
# awk -f split-totalcharges-to-subtotal-addlchrg.awk input_csvfile
#
# SQL to create the tsv to parse:
# SELECT EmailOrderId, FirstDate, FullName, Email1, TotalRetailCharge, Subtotal, AdditionalCharges
#   FROM LegacyEmailOrders_911
#   WHERE TotalRetailCharge != ''
#   INTO OUTFILE '/tmp/data/infiles/EmailOrdersTotalCharges.tsv';

BEGIN {
    FS = "\t"
    OFS = FS
    # Default only writes out 6 digits of precision ("%.6g")
    CONVFMT = OFMT = "%.2f"

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

    # strip leading and trailing spaces
    gsub(/^ +| +$/, "", totalCharge)

    # now strip a leading '$' and any following spaces
    # which won't affect the numeric value of the Subtotal
    sub(/^\$ */, "", totalCharge)
    #DEBUG: print("totalCharge: '" totalCharge "'") > "/dev/stderr"

    spaceIndex = index(totalCharge, " ")
    plusIndex = index(totalCharge, "+")
    if (plusIndex != 0) {
        addlChargesIndex = plusIndex
        if ((spaceIndex != 0) && (spaceIndex < plusIndex)) addlChargesIndex = spaceIndex + 1
    }
    else addlChargesIndex = spaceIndex + 1

    if(addlChargesIndex == 1) {
        SetSubtotal(totalCharge)
    }
    else {
        if (SetSubtotal(substr(totalCharge, 1, addlChargesIndex - 1))) {
            SetAdditionalCharges(substr(totalCharge, addlChargesIndex))
        }
    }

    print $0
}

function SetSubtotal(rawSubtotal)
{
    # strip all non digit & decimal point characters
    gsub(/[^0-9\.]/, "", rawSubtotal)

    if(length(rawSubtotal) != 0) {
        $Subtotal = rawSubtotal + 0
        return 1 # set subtotal
    }
    return 0 # did not set subtotal
}

function SetAdditionalCharges(rawAdditionalCharges)
{
    $AdditionalCharges = rawAdditionalCharges
}
