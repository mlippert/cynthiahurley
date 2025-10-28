LOAD DATA LOCAL INFILE '/tmp/data/infiles/WineMasterTable_09-23-3.csv'
REPLACE INTO TABLE LegacyWineMaster_923
FIELDS TERMINATED BY '|' OPTIONALLY ENCLOSED BY '"'
IGNORE 1 LINES
(
WineId,
AccountingItemNo,
NYPPItemNo,
WesternItemNo,
COLA_TTBID,
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
SubRegion,
Appellation,
CaseUnitType,
BottleSize,
BottlesPerCase,
BottleColor,
FrontLabelFilename,
BackLabelFilename,
ShelfTalkerText,
TastingNotes,
Vinification,
TerroirVineyardPractices,
PressParagraph,
ProducerName,
ProducerDescription,
ProducerCode,
YearEstablished,
COLA_PDF_Filename,
NJ_AssignedUPC,
NJ_BrandRegNo,
@CREATED,
@LASTUPDATED,
Excluded,
SoldOut,
PriceListSection,
PriceListNotes,
@FOBPrice,
FOB_ARB,
@NY_PP,
@NY_MultiCasePrice,
@NY_MultiCaseQty,
@NJ_PP,
@NJ_MultiCasePrice,
@NJ_MultiCaseQty,
NY_CurrentPricing,
NJ_CurrentPricing
)
SET
Vintage=if(@Vintage = 'NV', -1, @Vintage),
ABV=if(@ABV = '', NULL, @ABV),
DateCreated=if(@CREATED = '', NULL, @CREATED),
LastUpdated=if(@LASTUPDATED = '', NULL, @LASTUPDATED),
FOBPrice=if(@FOBPrice = '', NULL, @FOBPrice),
NY_PP=if(@NY_PP = '', NULL, @NY_PP),
NY_MultiCasePrice=if(@NY_MultiCasePrice = '', NULL, @NY_MultiCasePrice),
NY_MultiCaseQty=if(@NY_MultiCaseQty = '', NULL, @NY_MultiCaseQty),
NJ_PP=if(@NJ_PP = '', NULL, @NJ_PP),
NJ_MultiCasePrice=if(@NJ_MultiCasePrice = '', NULL, @NJ_MultiCasePrice),
NJ_MultiCaseQty=if(@NJ_MultiCaseQty = '', NULL, @NJ_MultiCaseQty);

CREATE TABLE LegacyWineMaster_923 (
                WineId INT NOT NULL,
                AccountingItemNo VARCHAR(11),
                NYPPItemNo VARCHAR(17),
                WesternItemNo VARCHAR(11),
                COLA_TTBID VARCHAR(15),
                UPC VARCHAR(13),
                FullName VARCHAR(114) NOT NULL,
                Vintage SMALLINT,
                Color VARCHAR(5),
                StillSparklingFortified VARCHAR(9),
                CertifiedOrganic VARCHAR(19),
                Varietals VARCHAR(100),
                ABV DECIMAL(5,2),
                Country VARCHAR(7),
                Region VARCHAR(20),
                SubRegion VARCHAR(20),
                Appellation VARCHAR(58),
                CaseUnitType VARCHAR(7),
                BottleSize VARCHAR(18),
                BottlesPerCase TINYINT,
                BottleColor VARCHAR(6),
                FrontLabelFilename VARCHAR(86),
                BackLabelFilename VARCHAR(53),
                ShelfTalkerText TEXT(1030),
                TastingNotes TEXT(1248),
                Vinification TEXT(1146),
                TerroirVineyardPractices TEXT(1359),
                PressParagraph TEXT(4660),
                ProducerName VARCHAR(58),
                ProducerDescription TEXT(1269),
                ProducerCode CHAR(3),
                YearEstablished VARCHAR(27),
                COLA_PDF_Filename VARCHAR(70),
                NJ_AssignedUPC VARCHAR(13),
                NJ_BrandRegNo VARCHAR(6),
                DateCreated DATE,
                LastUpdated DATETIME,
                Excluded VARCHAR(24),
                SoldOut CHAR(1),
                PriceListSection VARCHAR(39),
                PriceListNotes VARCHAR(144),
                FOBPrice DECIMAL(8,2),
                FOB_ARB VARCHAR(29),
                NY_PP DECIMAL(8,2),
                NY_MultiCasePrice DECIMAL(8,2),
                NY_MultiCaseQty TINYINT,
                NJ_PP DECIMAL(8,2),
                NJ_MultiCasePrice DECIMAL(8,2),
                NJ_MultiCaseQty TINYINT,
                NY_CurrentPricing VARCHAR(42),
                NJ_CurrentPricing VARCHAR(30),
                PRIMARY KEY (WineId)
);

SELECT
WineId,
AccountingItemNo,
NY_CurrentPricing,
NY_PP,
NY_MultiCasePrice,
NY_MultiCaseQty,
NJ_CurrentPricing,
NJ_PP,
NJ_MultiCasePrice,
NJ_MultiCaseQty
FROM LegacyWineMaster_923
INTO OUTFILE '/tmp/data/infiles/WinePricing_09-23.tsv'
;

/* To get permission to write to a file execute the following SQL statement AS the root user: */
GRANT FILE ON *.* TO chwuser;
/* Also change the folder permissions on the bound directory ie. chmod o+w data/infiles/ */

# Some vim macros for fixing the csv written by libreoffice Calc
:%s/^$/\\n/
:%s/\\n\n/\\n\\n/
:%s/\n\\n/\\n\\n/
:%s/\n"|/\\n"|/
:%s/\n\([^0-9][^0-9][^0-9][^0-9][^|]\)/\\n\1/
:%s/|"""/|"\\"/g
:%s/""/\\"/g

# fix LastUpdated date mm/dd/yyyy -> yyyy-mm-dd
:%s,|\(\d\{2}\)/\(\d\{2}\)/\(\d\{4}\) ,|\3-\1-\2 ,


LOAD DATA LOCAL INFILE '/tmp/data/infiles/EmailWineOrders_10-02-cleaned.csv'
REPLACE INTO TABLE LegacyEmailOrders_1002
FIELDS TERMINATED BY '|' OPTIONALLY ENCLOSED BY '"'
IGNORE 1 LINES
(
EmailOrderId,
OrderNumber,
@FirstDate,
@InqDate,
FullName,
LastName,
CompanyAptNo,
Street,
City,
State,
Zip,
PhoneHome,
PhoneWork,
FaxNumber,
Email,
Email1,
Source,
SubPaid,
CCVisa,
CCAmex,
CCMastercard,
CC_ID,
TotalRetailCharge,
@Subtotal,
AdditionalCharges,
Fax,
Quantity,
Quant2,
Quant3,
Quant4,
Quant5,
DelItemss,
DelItem2,
DelItem3,
DelItem4,
DelItem5,
@Vintage,
@Vintage2,
@Vintage3,
@Vintage4,
@Vintage5,
CustDetails
)
SET
FirstDate=if(LENGTH(@FirstDate) < 9, NULL, @FirstDate),
InqDate=if(LENGTH(@InqDate) < 9, NULL, @InqDate),
Subtotal=if(@Subtotal = '', NULL, @Subtotal),
Vintage=if(@Vintage REGEXP '^[0-9]{4}$', @Vintage, NULL),
Vintage2=if(@Vintage2 REGEXP '^[0-9]{4}$', @Vintage2, NULL),
Vintage3=if(@Vintage3 REGEXP '^[0-9]{4}$', @Vintage3, NULL),
Vintage4=if(@Vintage4 REGEXP '^[0-9]{4}$', @Vintage4, NULL),
Vintage5=if(@Vintage5 REGEXP '^[0-9]{4}$', @Vintage5, NULL)
;

CREATE TABLE LegacyEmailOrders_1002 (
                EmailOrderId INT NOT NULL,
                OrderNumber VARCHAR(10),
                FirstDate DATE,
                InqDate DATE,
                FullName VARCHAR(69),
                LastName VARCHAR(26),
                CompanyAptNo VARCHAR(56),
                Street VARCHAR(102),
                City VARCHAR(39),
                State VARCHAR(14),
                Zip VARCHAR(14),
                PhoneHome VARCHAR(44),
                PhoneWork VARCHAR(30),
                FaxNumber VARCHAR(22),
                Email TEXT(965),
                Email1 TEXT(490),
                Source VARCHAR(38),
                SubPaid VARCHAR(23),
                CCVisa VARCHAR(61),
                CCAmex VARCHAR(90),
                CCMastercard VARCHAR(81),
                CC_ID VARCHAR(39),
                TotalRetailCharge VARCHAR(101),
                Subtotal DECIMAL(8,2),
                AdditionalCharges VARCHAR(120),
                Fax VARCHAR(33),
                Quantity VARCHAR(37),
                Quant2 VARCHAR(24),
                Quant3 VARCHAR(34),
                Quant4 VARCHAR(36),
                Quant5 VARCHAR(22),
                DelItemss VARCHAR(88),
                DelItem2 TEXT(2089),
                DelItem3 VARCHAR(71),
                DelItem4 VARCHAR(73),
                DelItem5 VARCHAR(71),
                Vintage SMALLINT,
                Vintage2 SMALLINT,
                Vintage3 SMALLINT,
                Vintage4 SMALLINT,
                Vintage5 SMALLINT,
                CustDetails TEXT(1130),
                PRIMARY KEY (EmailOrderId)
);

/*
Notes about LegacyEmailOrders_1002
26511 Order Records
 4823 Distinct FullName
  371 FullName == ''
  187 FullName LIKE ' %' (starts with a space)
    1 FullName LIKE '\n%' (starts with a newline)
    9 FullName LIKE '%\n%' (contains a newline)
 2873 Distinct Email1
 5601 Email1 == ''
  155 Distinct Email1 LIKE ' %' (starts with a space)
    1 Distinct Email1 LIKE '\n%' (starts with a newline)
  226 Distinct Email1 LIKE '%\n%' (contains a newline)

 5437 Distinct FullName, Email1
 5148 Distinct FullName, Email1 with FullName != ''
 3139 Distinct FullName, Email1 with Email1 != ''
 2851 Distinct FullName, Email1 with FullName != '' AND Email1 != ''
 1287 Distinct FullName, Email1 with FullName != '' AND Email1 != '' AND NumberOfOrders > 1
  601 Distinct FullName, Email1 with FullName != '' AND Email1 != '' AND NumberOfOrders > 1 AND Year >= 2016

Query for that last follows:
*/
SELECT FullName, Email1, COUNT( FullName ) NumberOfOrders, YEAR( FirstDate ) Year
FROM chw.LegacyEmailOrders_1002
WHERE FullName != '' AND Email1 != '' AND YEAR( FirstDate ) >= 2016
GROUP BY FullName, Email1
HAVING NumberOfOrders > 1
ORDER BY FullName ASC
;

/* qryEmailOrdersWithTotalCharge */
SELECT EmailOrderId, FirstDate, FullName, Email1, TotalRetailCharge, Subtotal, AdditionalCharges
FROM LegacyEmailOrders_1002
WHERE TotalRetailCharge != ''
INTO OUTFILE '/tmp/data/infiles/EmailOrdersTotalCharges_10-02.tsv'
;

CREATE TABLE LegacyEmailOrdersTotals_1002 (
                EmailOrderId INT NOT NULL,
                TotalRetailCharge VARCHAR(101),
                Subtotal DECIMAL(8,2),
                AdditionalCharges VARCHAR(120),
                PRIMARY KEY (EmailOrderId)
);

LOAD DATA LOCAL INFILE '/tmp/data/infiles/EmailOrdersTotalCharges_10-02_SplitInNewFields.tsv'
REPLACE INTO TABLE LegacyEmailOrdersTotals_1002
FIELDS OPTIONALLY ENCLOSED BY '"'
IGNORE 1 LINES
(
EmailOrderId,
@FirstDate,
@FullName,
@Email1,
TotalRetailCharge,
@Subtotal,
AdditionalCharges
)
SET
Subtotal=if(@Subtotal = '', NULL, @Subtotal)
;

SELECT YEAR( EOrders.FirstDate ) AS Year, EOrders.FullName FullName, SUM( `EOTotals`.`Subtotal` ) AS Total
FROM chw.LegacyEmailOrders_1002 AS EOrders, chw.LegacyEmailOrdersTotals_1002 AS EOTotals
WHERE EOrders.EmailOrderId = EOTotals.EmailOrderId GROUP BY Year, FullName ORDER BY Year ASC, FullName ASC
;

SELECT
    YEAR( Orders.FirstDate ) Year,
    Orders.FullName,
    COUNT( Orders.FullName ) NumOrders,
    SUM( OrderTotals.Subtotal ) Total
FROM
    chw.LegacyEmailOrders_1002 Orders,
    chw.LegacyEmailOrdersTotals_1002 OrderTotals
WHERE OrderTotals.EmailOrderId = Orders.EmailOrderId
GROUP BY Orders.FullName, YEAR( Orders.FirstDate )
ORDER BY Year ASC, Total ASC
;

/* using JOIN syntax instead of WHERE */
SELECT
    YEAR( Orders.FirstDate ) Year,
    Orders.FullName,
    COUNT( Orders.FullName ) NumOrders,
    SUM( OrderTotals.Subtotal ) Total
FROM
    chw.LegacyEmailOrders_1002 Orders INNER JOIN chw.LegacyEmailOrdersTotals_1002 OrderTotals
    ON Orders.EmailOrderId = OrderTotals.EmailOrderId
GROUP BY Orders.FullName, YEAR( Orders.FirstDate )
ORDER BY Year ASC, Total ASC
;

/* Customers Since 2020 Total of all orders ever */
/* Customer Total orders since 2020 - Add WHERE clause YEAR(Orders.FirstDate) >= 2020 */
SELECT
    Orders.FullName, Orders.Email1,
    SUM( OrderTotals.Subtotal ) Total,
    MIN( YEAR( Orders.FirstDate ) ) YearOfFirstOrder,
    MAX( YEAR( Orders.FirstDate ) ) YearOfLastOrder,
    COUNT( Orders.FullName ) NumberOfOrders
FROM
    chw.LegacyEmailOrders_1002 Orders INNER JOIN chw.LegacyEmailOrdersTotals_1002 OrderTotals
    ON Orders.EmailOrderId = OrderTotals.EmailOrderId
GROUP BY Orders.FullName
HAVING ( ( YearOfLastOrder >= 2020 ) )
ORDER BY Total ASC, Orders.FullName ASC
;


SELECT
    EC.EmailCustomerId EmailCustomerId,
    EC.GivenName GivenName,
    EC.Surname Surname,
    EC.Email Email,
    LEO.FirstDate OrderDate,
    LEO.DelItemss Item
FROM chw.EmailCustomers EC
JOIN chw.EmailCustomers_LegacyEmailOrders EC_LEO
  ON EC.EmailCustomerId = EC_LEO.EmailCustomerId
JOIN chw.LegacyEmailOrders_1002 LEO
  ON LEO.EmailOrderId = EC_LEO.EmailOrderId
UNION ALL
(SELECT
    EC.EmailCustomerId,
    EC.GivenName,
    EC.Surname,
    EC.Email,
    LEO.FirstDate,
    LEO.DelItem2
FROM chw.EmailCustomers EC
JOIN chw.EmailCustomers_LegacyEmailOrders EC_LEO
  ON EC.EmailCustomerId = EC_LEO.EmailCustomerId
JOIN chw.LegacyEmailOrders_1002 LEO
  ON LEO.EmailOrderId = EC_LEO.EmailOrderId)
WHERE EC.EmailCustomerId IN
(10946,
10500,
10770,
11155,
9313,
13635,
10858,
12396,
13028,
11719,
11050,
13786,
11383,
11979)
ORDER BY EmailCustomerId ASC, OrderDate ASC

SELECT
    EC.EmailCustomerId,
    EC.GivenName,
    EC.Surname,
    EC.Email,
    LEO.FirstDate OrderDate,
    LEO.DelItemss,
    LEO.DelItem2,
    LEO.DelItem3,
    LEO.DelItem4,
    LEO.DelItem5,
    LEO.Vintage,
    LEO.Vintage2,
    LEO.Vintage3,
    LEO.Vintage4,
    LEO.Vintage5,
    LEO.Quantity,
    LEO.Quant2,
    LEO.Quant3,
    LEO.Quant4,
    LEO.Quant5
FROM chw.EmailCustomers EC
JOIN chw.EmailCustomers_LegacyEmailOrders EC_LEO
  ON EC.EmailCustomerId = EC_LEO.EmailCustomerId
JOIN chw.LegacyEmailOrders_1002 LEO
  ON LEO.EmailOrderId = EC_LEO.EmailOrderId
WHERE EC.EmailCustomerId IN
(10946,
10500,
10770,
11155,
9313,
13635,
10858,
12396,
13028,
11719,
11050,
13786,
11383,
11979,
11630,
9600,
11646)
ORDER BY EC.EmailCustomerId ASC, OrderDate ASC
