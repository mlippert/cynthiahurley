/* To get permission to write to a file execute the following SQL statement AS the root user: */
GRANT FILE ON *.* TO chwuser;
/* Also change the folder permissions on the bound directory ie. chmod o+w data/infiles/ */

/*
 * Load the LegacyWineMaster_NNNN table from a delimited file in the "infiles" directory
 * NNNN == 1218 as of the last update of the snippet
 */
LOAD DATA LOCAL INFILE '/tmp/data/infiles/WineMasterTable_12-18-xform.csv'
REPLACE INTO TABLE LegacyWineMaster_1218
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


/* We may need to create Producer records with python so that we can track differences */
INSERT INTO Producers ()

/* Add a constraint on some Wines columns limiting them to specific values */
ALTER TABLE Wines ADD CONSTRAINT Wines_UnitsPerCase_chk CHECK (UnitsPerCase IN (1, 3, 6, 12, 24, 48));
ALTER TABLE Wines ADD CONSTRAINT Wines_BottleColor_chk CHECK (BottleColor IN ('Brown', 'Green', 'Clear', 'CAN')); /* NULL allowed */

/* TODO
python code to set CaseUnitId?
*/
INSERT INTO Wines
(
    WineId,
    AccountingItemNo,
    COLA_TTB_ID,
    UPC,
    FullName,
    WineName,
    Vintage,
    WineColorId,
    WineTypeId,
    CertifiedOrganic,
    Varietals,
    ABV,
    Country,
    Region,
    Subregion,
    Appellation,
    ProducerId,
    UnitsPerCase,
    CaseUnitId,
    BottleColor,
    ShelfTalkerText,
    TastingNotes,
    Vinification,
    TerroirVineyardPractices,
    PressParagraph,
    Exporter,
    LastPurchasePrice,
    LastPurchaseDate,
    Created,
    CreatedBy,
    LastModified,
    LastModifiedBy
)
SELECT
    LWM.WineId,
    LWM.AccountingItemNo,
    if(LWM.COLA_TTB_ID = '', 'Pending', LWM.COLA_TTB_ID),
    if(LWM.UPC = '', NULL, LWM.UPC),
    LWM.FullName,
    LWM.WineName,
    LWM.Vintage,
    LkupWC.WineColorId,
    LkupWT.WineTypeId,
    if(CertifiedOrganic = 'certified organic', TRUE, FALSE),
    LWM.Varietals,
    if(LWM.ABV IS NULL, -1, LWM.ABV),
    LWM.Country,
    LWM.Region,
    LWM.Subregion,
    LWM.Appellation,
    WP.ProducerId,
    LWM.BottlesPerCase,
    0,
    if(LWM.BottleColor = '', NULL, LWM.BottleColor),
    LWM.ShelfTalkerText,
    LWM.TastingNotes,
    LWM.Vinification,
    LWM.TerroirVineyardPractices,
    LWM.PressParagraph,
    LWM.Exporter,
    LWM.LastPurchasePrice,
    LWM.LastPurchaseDate,
    if(LWM.DateCreated IS NULL, LWM.LastUpdated, LWM.DateCreated),
    'Legacy',
    LWM.LastUpdated,
    'Legacy'
FROM LegacyWineMaster_1218 LWM
INNER JOIN LookupWineTypes LkupWT
  ON LWM.StillSparklingFortified = LkupWT.WineType
INNER JOIN LookupWineColors LkupWC
  ON LWM.Color = LkupWC.WineColor
LEFT JOIN Producers WP
  ON LWM.ProducerName = WP.Name
