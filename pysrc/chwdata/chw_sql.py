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
    CHW_SQL provides the sql statements used by to operate on the mariadb chw
    database tables and other entities.

    As sql statements can be long and span many lines encapsulating them in
    this class helps organize them and allows the code where they are used to
    be more easily read.
    """

    # Format string to create a Sql Load Data statement to load the legacy wine master table
    # where parameters datadir, csvfile, suffix must be supplied.
    # used by get_legacy_wine_master_load_data method
    _legacy_email_orders_load_data_sql_fmt = """
LOAD DATA INFILE '{datadir}{csvfile}'
REPLACE INTO TABLE LegacyEmailOrders{suffix}
FIELDS TERMINATED BY '|' OPTIONALLY ENCLOSED BY '"'
IGNORE 1 LINES
(
EmailOrderId,
OrderNumber,
@FirstDate,
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
Retailer,
Quantity,
DelItems,
@Vintage,
Quant2,
DelItem2,
@Vintage2,
Quant3,
DelItem3,
@Vintage3,
Quant4,
DelItem4,
@Vintage4,
Quant5,
DelItem5,
@Vintage5,
CustDetails
)
SET
FirstDate=if(LENGTH(@FirstDate) < 9, NULL, @FirstDate),
Subtotal=if(@Subtotal = '', NULL, @Subtotal),
Vintage=if(@Vintage REGEXP '^[0-9]{{4}}$', @Vintage, NULL),
Vintage2=if(@Vintage2 REGEXP '^[0-9]{{4}}$', @Vintage2, NULL),
Vintage3=if(@Vintage3 REGEXP '^[0-9]{{4}}$', @Vintage3, NULL),
Vintage4=if(@Vintage4 REGEXP '^[0-9]{{4}}$', @Vintage4, NULL),
Vintage5=if(@Vintage5 REGEXP '^[0-9]{{4}}$', @Vintage5, NULL)
;
"""

    # Select statement to retrieve unique email customer fullnames from
    unique_fullname_sql = """
SELECT FullName, COUNT( FullName ) NumOrders
  FROM chw.LegacyEmailOrders_1106
 WHERE FullName != ''
 GROUP BY FullName
 ORDER BY FullName ASC
"""

    # Select statement for Customer columns of ALL LegacyEmailOrders records with a matching FullName
    legacy_customer_info_columns = ('EmailOrderId',
                                    'FirstDate',
                                    'FullName',
                                    'LastName',
                                    'Email1',
                                    'CompanyAptNo',
                                    'Street',
                                    'City',
                                    'State',
                                    'Zip',
                                    'PhoneHome',
                                    'PhoneWork',
                                    'FaxNumber',
                                    'CCVisa',
                                    'CCAmex',
                                    'CCMastercard',
                                    'CC_ID'
                                   )
    legacy_customer_info_sql = ('SELECT ' + ', '.join(legacy_customer_info_columns) +
                                ' FROM chw.LegacyEmailOrders_1106'
                                ' WHERE FullName = ?'
                                ' ORDER BY FirstDate ASC'
                               )

    # Insert statement to create EmailCustomer record
    insert_email_customer_sql = """
INSERT INTO chw.EmailCustomers
 ( Title
 , GivenName
 , Surname
 , Suffix
 , Email
 , Created
 , CreatedBy
 , LastModified
 , LastModifiedBy
 )
 VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
"""

    # Insert statement to create EmailCustomers_LegacyEmailOrders record
    insert_customer_legacyorder_sql = """
INSERT INTO chw.EmailCustomers_LegacyEmailOrders
 ( EmailCustomerId
 , EmailOrderId
 , NameNeedsReview
 , EmailNeedsReview
 , ConversionNotes
 )
 VALUES (?, ?, ?, ?, ?)
"""

    # List is only used in the following example sql statement with multiple joins
    _orders_of_top_customers_columns = ('EC.EmailCustomerId,',
                                        'EC.GivenName',
                                        'EC.Surname',
                                        'EC.Email',
                                        'LEO.FirstDate OrderDate',
                                        'LEO.DelItemss',
                                        'LEO.DelItem2',
                                        'LEO.DelItem3',
                                        'LEO.DelItem4',
                                        'LEO.DelItem5',
                                        'LEO.Vintage',
                                        'LEO.Vintage2',
                                        'LEO.Vintage3',
                                        'LEO.Vintage4',
                                        'LEO.Vintage5',
                                        'LEO.Quantity',
                                        'LEO.Quant2',
                                        'LEO.Quant3',
                                        'LEO.Quant4',
                                        'LEO.Quant5'
                                       )

    # NOTE: Example sql select w/ join of multiple tables, not currently being used.
    _orders_of_top_customers2_sql = ('SELECT ' + ', '.join(_orders_of_top_customers_columns) + """
FROM chw.EmailCustomers EC
JOIN chw.EmailCustomers_LegacyEmailOrders EC_LEO
  ON EC.EmailCustomerId = EC_LEO.EmailCustomerId
JOIN chw.LegacyEmailOrders_1106 LEO
  ON LEO.EmailOrderId = EC_LEO.EmailOrderId
WHERE EC.EmailCustomerId IN
(10946, 10500, 10770, 11155, 9313, 13635, 10858, 12396, 13028, 11719, 11050, 13786, 11383, 11979,
 11630, 9600, 11646)
ORDER BY EC.EmailCustomerId ASC, OrderDate ASC
""")

    # List, supplied by Gilli, of the emails of the top customers for the report of the wines they
    # have ordered.
    _top_customers_emails = ('kcweiner@texcrude.com',
                             'Jack.Ende@uphs.upenn.edu',
                             'jchilds@jwchilds.com',
                             'lukecorsten@yahoo.com',
                             'Steve.Ezell@landcorp.com',
                             'Joseph.Losee@chp.edu',
                             'philip.mengel@gmail.com',
                             'njmoult@yahoo.com ',
                             'BCLindsay@aol.com',
                             'lewoolcott@gmail.com ',
                             'tpotter@capdale.com',
                             'michael.a.gangemi@gmail.com',
                             'wagner@clearbrookadvisors.com',
                             'alitt4383@aol.com',
                             'byronagrant@gmail.com',
                             'adupont@craneco.com',
                             'cis@mosbacherproperties.com',
                             'cek@mosbacherproperties.com'
                            )
    # Select statement for the wines in the orders of the top customers in the legacy email order table
    orders_of_top_customers_sql = ("""
SELECT EC.EmailCustomerId
     , EC.GivenName
     , EC.Surname
     , EC.Email
     , LEO.PhoneHome
     , LEO.FirstDate OrderDate
     , U.EmailOrderId
     , U.Item
     , U.Vintage
     , U.Quantity
 FROM ((SELECT EmailOrderId, DelItems AS Item, Vintage, Quantity
        FROM LegacyEmailOrders_1106
        WHERE DelItems != ''
       )
       UNION ALL
       (SELECT EmailOrderId, DelItem2, Vintage2, Quant2
        FROM LegacyEmailOrders_1106
        WHERE DelItem2 != ''
       )
       UNION ALL
       (SELECT EmailOrderId, DelItem3, Vintage3, Quant3
        FROM LegacyEmailOrders_1106
        WHERE DelItem3 != ''
       )
       UNION ALL
       (SELECT EmailOrderId, DelItem4, Vintage4, Quant4
        FROM LegacyEmailOrders_1106
        WHERE DelItem4 != ''
       )
       UNION ALL
       (SELECT EmailOrderId, DelItem5, Vintage5, Quant5
        FROM LegacyEmailOrders_1106
        WHERE DelItem5 != ''
       )
      ) AS U
 JOIN LegacyEmailOrders_1106 AS LEO ON U.EmailOrderId = LEO.EmailOrderId
 JOIN EmailCustomers_LegacyEmailOrders AS EC_LEO ON U.EmailOrderId = EC_LEO.EmailOrderId
 JOIN EmailCustomers AS EC ON EC_LEO.EmailCustomerId = EC.EmailCustomerId
 WHERE EC.Email IN ('""" + "', '".join(_top_customers_emails) + """')
 OR (EC.GivenName = 'Alexander' AND EC.Surname = 'Kinsey')
 ORDER BY Email ASC, OrderDate ASC
"""
)

    # Format string to create a Sql Load Data statement to load the legacy wine master table
    # where parameters datadir, csvfile, suffix must be supplied.
    # used by get_legacy_wine_master_load_data method
    _legacy_wine_master_load_data_sql_fmt = """
LOAD DATA INFILE '{datadir}{csvfile}'
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

    # Select statement to retrieve producer's wines ordered by producer then descending dates
    legacy_wines_by_producer_sql = """
SELECT WineId
     , ProducerName
     , ProducerDescription
     , ProducerCode
     , YearEstablished
  FROM chw.LegacyWineMaster_1106
 ORDER BY ProducerName ASC, LastUpdated DESC
;
"""

    # Insert statement to create Producer record
    insert_producer_sql = """
INSERT INTO chw.Producers
    ( Name
    , Description
    , ProducerCode
    , YearEstablished
    )
 VALUES (?, ?, ?, ?)
;
"""

    # Insert statement to create Producers_LegacyWineMaster record
    insert_producer_legacywine_sql = """
INSERT INTO chw.Producers_LegacyWineMaster
    ( ProducerId
    , WineId
    , ConversionNotes
    )
 VALUES (?, ?, ?)
"""


    @classmethod
    def get_legacy_email_orders_load_data(cls, params):
        """
        Returns the sql statement to load a csv data file containing legacy email orders
        records into the LegacyEmailOrders table with the given suffix.

        params is a dictionary with suffix, csvfile and datadir keys to be inserted
        into the sql format string being returned.
        """
        return cls._legacy_email_orders_load_data_sql_fmt.format(**params)

    @classmethod
    def get_legacy_wine_master_load_data(cls, params):
        """
        Returns the sql statement to load a csv data file containing legacy wine master
        records into the LegacyWineMaster table with the given suffix.

        params is a dictionary with suffix, csvfile and datadir keys to be inserted
        into the sql format string being returned.
        """
        return cls._legacy_wine_master_load_data_sql_fmt.format(**params)
