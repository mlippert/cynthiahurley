"""
################################################################################
  chw_sql.py
################################################################################

This module provides SQL statements for working with the CHW database tables.

Python naming convention reminder note: single underscore prefix class names are
for "private" internal use and should not be considered part of the public API.

=============== ================================================================
Created on      December 6, 2025
--------------- ----------------------------------------------------------------
author(s)       Michael Jay Lippert
--------------- ----------------------------------------------------------------
Copyright       (c) 2025-present Michael Jay Lippert
                MIT License (see https://opensource.org/licenses/MIT)
=============== ================================================================
"""

# Standard library imports

# Third party imports

# Local application imports


class CHW_SQL:
    """
    """

    _legacy_wine_master_load_data_sql_fmt = """
LOAD DATA LOCAL INFILE '{datadir}{csvfile}'
REPLACE INTO TABLE LegacyWineMaster{suffix}
FIELDS TERMINATED BY '|' OPTIONALLY ENCLOSED BY '"'
IGNORE 1 LINES
(
WineId,
AccountingItemNo,
NYPPItemNo,
WesternItemNo,
COLA_TTB_ID,
UPC,
FullName,
@Vintage,
Color,
StillSparklingFortified,
CertifiedOrganic,
Varietals,
@ABV,
Country,
Region,
Subregion,
Appellation,
CaseUnitType,
BottleSize,
BottlesPerCase,
BottleColor,
ShelfTalkerText,
TastingNotes,
Vinification,
TerroirVineyardPractices,
PressParagraph,
ProducerName,
ProducerDescription,
ProducerCode,
YearEstablished,
Exporter,
NJ_AssignedUPC,
NJ_BrandRegNo,
@LastPurchasePrice,
@LastPurchaseDate,
@CREATED,
@LASTUPDATED,
Excluded,
SoldOut,
PriceListSection,
PriceListNotes,
@FOBPrice,
@FOB_MA,
@FOB_ARB,
ARB_Comment,
@NY_Wholesale,
@NY_MultiCasePrice,
@NY_MultiCaseQty,
@NJ_Wholesale,
@NJ_MultiCasePrice,
@NJ_MultiCaseQty,
PriceNotes,
@AE_Record_Id,
NY_CurrentPricing,
NJ_CurrentPricing,
MA_CurrentPricing,
FrontLabelFilename,
BackLabelFilename,
COLA_PDF_Filename
)
SET
Vintage=if(@Vintage = 'NV', -1, @Vintage),
ABV=if(@ABV = '', NULL, @ABV),
DateCreated=if(@CREATED = '', NULL, @CREATED),
LastUpdated=if(@LASTUPDATED = '', NULL, @LASTUPDATED),
LastPurchasePrice=if(@LastPurchasePrice = '', NULL, @LastPurchasePrice),
LastPurchaseDate=if(@LastPurchaseDate = '', NULL, @LastPurchaseDate),
FOBPrice=if(@FOBPrice = '', NULL, @FOBPrice),
FOB_MA=if(@FOB_MA = '', NULL, @FOB_MA),
FOB_ARB=if(@FOB_ARB = '', NULL, @FOB_ARB),
NY_Wholesale=if(@NY_Wholesale = '', NULL, @NY_Wholesale),
NY_MultiCasePrice=if(@NY_MultiCasePrice = '', NULL, @NY_MultiCasePrice),
NY_MultiCaseQty=if(@NY_MultiCaseQty = '', NULL, @NY_MultiCaseQty),
NJ_Wholesale=if(@NJ_Wholesale = '', NULL, @NJ_Wholesale),
NJ_MultiCasePrice=if(@NJ_MultiCasePrice = '', NULL, @NJ_MultiCasePrice),
NJ_MultiCaseQty=if(@NJ_MultiCaseQty = '', NULL, @NJ_MultiCaseQty),
AE_Record_Id=if(@AE_Record_Id = '', NULL, @AE_Record_Id);
"""

    @classmethod
    def get_legacy_wine_master_load_data(cls, params):
        """
        Returns the sql statement to load a csv data file containing legacy wine master
        records into the LegacyWineMaster table with the given suffix.

        params is a dictionary with suffix, csvfile and datadir keys to be inserted
        into the sql format string being returned.
        """
        return cls._legacy_wine_master_load_data_sql_fmt.format(**params)
