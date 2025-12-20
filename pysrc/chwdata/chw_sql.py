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

    # Format string to create a Sql Load Data statement to load the legacy email orders table
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

    ############################
    #
    # Wine Table sql statements
    #
    ############################

    # Insert statements to set up wine related lookup tables
    insert_lookup_wine_colors_sql = """
INSERT IGNORE INTO LookupWineColors
VALUES (-1, 'TBD'), (1, 'White'), (2, 'Red'), (3, 'Rosé')
"""

    insert_lookup_wine_types_sql = """
INSERT IGNORE INTO LookupWineTypes
VALUES (-1, 'TBD'), (1, 'Still'), (2, 'Sparkling'), (3, 'Fortified')
"""

    insert_lookup_case_units_sql = """
INSERT IGNORE INTO LookupCaseUnits
VALUES (-1,'Unknown',          'unknown', 'ml',      0.0,    0),
       (1, 'Bottle 750ml',     'bottle',  'ml',    750.0,  750),
       (2, 'Magnum 1.5 Liter', 'bottle',  'Liter',   1.5, 1500),
       (3, 'Bottle 375ml',     'bottle',  'ml',    375.0,  375),
       (4, 'BiB 3 Liter',      'BiB',     'Liter',   3.0, 3000),
       (5, 'BiB 6 Liter',      'BiB',     'Liter',   6.0, 6000),
       (6, 'Can 250ml',        'can',     'ml',    250.0,  250),
       (7, 'Can 500ml',        'can',     'ml',    500.0,  500)
"""

    insert_lookup_wine_countries_sql = """
INSERT IGNORE INTO LookupWineCountries
VALUES (1, 'France'), (2, 'Germany'), (3, 'Italy'), (4, 'Spain')
"""

    insert_lookup_wine_regions_sql = """
INSERT IGNORE INTO LookupWineRegions
VALUES (1, 'Alsace'),
       (2, 'Bordeaux'),
       (3, 'Burgundy'),
       (4, 'Castile-Léon'),
       (5, 'Catalonia'),
       (6, 'Champagne'),
       (7, 'Corsica'),
       (8, 'Galicia'),
       (9, 'Languedoc'),
       (10, 'Loire'),
       (11, 'Penedes'),
       (12, 'Piedmont'),
       (13, 'Provence'),
       (14, 'Rhein'),
       (15, 'Rhône'),
       (16, 'Rias Baixas'),
       (17, 'Ribera del Duero'),
       (18, 'Rioja'),
       (19, 'Roussillon'),
       (20, 'Southwest')
"""

    insert_lookup_wine_subregions_sql = """
INSERT IGNORE INTO LookupWineSubregions
VALUES (1, 'Beaujolais'),
       (2, 'Beaujolais Cru'),
       (3, 'Chablis'),
       (4, 'Cote Chalonnaise'),
       (5, 'Cote de Beaune'),
       (6, 'Côte de Nuits'),
       (7, 'Langhe'),
       (8, 'Limoux'),
       (9, 'Mâconnais'),
       (10, 'Northern Rhône'),
       (11, 'Sauternes'),
       (12, 'Southern Rhône'),
       (13, 'Val do Salnes')
"""

    insert_lookup_wine_appellations_sql = """
INSERT IGNORE INTO LookupWineAppellations
VALUES (1, 'Alsace'),
       (2, 'AOP-Languedoc'),
       (3, 'Bararesco'),
       (4, 'Barbaresco'),
       (5, 'Barbera d\\\'Alba'),
       (6, 'Barbera d\\\'Asti'),
       (7, 'Barolo'),
       (8, 'Beaujolais'),
       (9, 'Beaujolais Villages'),
       (10, 'Beaune 1er Cru Les Teurons'),
       (11, 'Bierzo'),
       (12, 'Blanquette de Limoux'),
       (13, 'Bordeaux'),
       (14, 'Bordeaux Blanc'),
       (15, 'Bordeaux Superieur'),
       (16, 'Bordeaux Superieur Rouge'),
       (17, 'Bordeaux Superieure'),
       (18, 'Bourgogne'),
       (19, 'Bourgogne Aligoté'),
       (20, 'Cahors'),
       (21, 'Cairanne'),
       (22, 'Canon Fronsac'),
       (23, 'Castillon Côtes de Bordeaux'),
       (24, 'Cava'),
       (25, 'Chablis'),
       (26, 'Chablis 1er Cru Forets'),
       (27, 'Chablis 1er Cru Homme Mort'),
       (28, 'Chablis 1er Cru Montee de Tonnerre'),
       (29, 'Chablis 1er Cru Vaillons'),
       (30, 'Chablis Grand Cru Grenouilles'),
       (31, 'Chambolle Musigny'),
       (32, 'Champagne, 1er Cru'),
       (33, 'Champagne, Cramant'),
       (34, 'Champagne, Grand Cru'),
       (35, 'Chassagne Montrachet'),
       (36, 'Chassagne Montrachet 1er Cru les Chaumées'),
       (37, 'Chassagne Montrachet 1er Cru les Chevenottes'),
       (38, 'Chassagne Montrachet 1er Cru les Embrazées'),
       (39, 'Chassagne Montrachet 1er Cru les Macherelles'),
       (40, 'Châteauneuf du Pape'),
       (41, 'Chinon'),
       (42, 'Chiroubles'),
       (43, 'Collines Rhodaniennes'),
       (44, 'Conca de Barbera'),
       (45, 'Condrieu'),
       (46, 'Cornas'),
       (47, 'Cote de Brouilly'),
       (48, 'Côte Rotie'),
       (49, 'Coteaux d\\\'Aix-en-Provence'),
       (50, 'Coteaux de Languedoc'),
       (51, 'Côtes de Bourg'),
       (52, 'Côtes de Gascogne'),
       (53, 'Côtes du Rhône'),
       (54, 'Côtes du Rhône Villages'),
       (55, 'Côtes du Rhône Villages Cairanne'),
       (56, 'Côtes du Rhône Villages Seguret'),
       (57, 'Côtes du Rhône Villages Visan'),
       (58, 'Cotes du Roussillon Villages'),
       (59, 'Crémant de Limoux'),
       (60, 'Crozes Hermitage'),
       (61, 'Faugeres'),
       (62, 'Francs Côtes de Bordeaux'),
       (63, 'Fronsac'),
       (64, 'Gevrey Chambertin'),
       (65, 'Gevrey Chambertin 1er Cru Combe aux Moines'),
       (66, 'Gevrey Chambertin 1er Cru les Cazetiers'),
       (67, 'Gigondas'),
       (68, 'Grand Cru Batard Montrachet'),
       (69, 'Grand Cru Bienvenues Batard Montrachet'),
       (70, 'Grand Cru Bonnes Mares'),
       (71, 'Grand Cru Chambertin'),
       (72, 'Grand Cru Chambertin Clos de Beze'),
       (73, 'Grand Cru Champagne, Bouzy'),
       (74, 'Grand Cru Champagne, Cramant'),
       (75, 'Grand Cru Chevalier Montrachet'),
       (76, 'Grand Cru Clos Vougeot'),
       (77, 'Grand Cru Corton Charlemagne'),
       (78, 'Grand Cru Criots Batard Montrachet'),
       (79, 'Grand Cru Echezeaux'),
       (80, 'Grand Cru Latricieres Chambertin'),
       (81, 'Grand Cru Le Montrachet'),
       (82, 'Graves'),
       (83, 'Haut-Medoc'),
       (84, 'Hermitage'),
       (85, 'IGP Cotes Catalanes'),
       (86, 'IGP-Saint Guilhem Le Désert'),
       (87, 'Lalande de Pomerol'),
       (88, 'Langhe'),
       (89, 'Mâcon Villages'),
       (90, 'Mâcon-Solutré'),
       (91, 'Madiran'),
       (92, 'Margaux'),
       (93, 'Maury Sec'),
       (94, 'Medoc'),
       (95, 'Mercurey 1er Cru les Crets'),
       (96, 'Meursault'),
       (97, 'Meursault 1er Cru Clos Richemont'),
       (98, 'Meursault 1er Cru les Charmes'),
       (99, 'Meursault 1er Cru les Genevrieres'),
       (100, 'Meursault 1er Cru les Gouttes D\\\'Or'),
       (101, 'Meursault 1er Cru les Perrieres'),
       (102, 'Meursault 1er Cru les Poruzots'),
       (103, 'Minervois'),
       (104, 'Montagny'),
       (105, 'Montagny 1er Cru'),
       (106, 'Monthelie'),
       (107, 'Monthelie 1er Cru Clou de Chenes'),
       (108, 'Morgon'),
       (109, 'Moulis'),
       (110, 'Muscadet Sevre-et-Maine'),
       (111, 'Pacherenc du Vin Bilh'),
       (112, 'Patrimonio'),
       (113, 'Pauillac'),
       (114, 'Pays d\\\'Oc'),
       (115, 'Penedes'),
       (116, 'Pessac Leognan'),
       (117, 'Petit Chablis'),
       (118, 'Pic Saint Loup'),
       (119, 'Pomerol'),
       (120, 'Pommard'),
       (121, 'Pommard 1er Cru les Rugiens'),
       (122, 'Pouilly Fuisse'),
       (123, 'Pouilly Fume'),
       (124, 'Pouilly-Fuissé'),
       (125, 'Pouilly-Loché'),
       (126, 'Priorat'),
       (127, 'Puisseguin Saint-Emilion'),
       (128, 'Puligny Montrachet'),
       (129, 'Puligny Montrachet 1er Cru Clos de la Mouchere'),
       (130, 'Puligny Montrachet 1er Cru les Caillerets'),
       (131, 'Puligny Montrachet 1er Cru les Combettes'),
       (132, 'Puligny Montrachet 1er Cru les Folatieres'),
       (133, 'Puligny Montrachet 1er Cru les Perrieres'),
       (134, 'Puligny Montrachet 1er Cru les Pucelles'),
       (135, 'Rasteau'),
       (136, 'Régnié'),
       (137, 'Rias Baixas'),
       (138, 'Ribeira Sacra'),
       (139, 'Rioja'),
       (140, 'Rueda'),
       (141, 'Rully'),
       (142, 'Rully 1er Cru Gresigny'),
       (143, 'Rully 1er Cru Preaux'),
       (144, 'Saint-Aubin'),
       (145, 'Saint-Aubin 1er Cru Clos du Meix'),
       (146, 'Saint-Estephe'),
       (147, 'Saint-Romain'),
       (148, 'Sancerre'),
       (149, 'Saumur'),
       (150, 'Saumur Champigny'),
       (151, 'Sauternes'),
       (152, 'Savigny les Beaune 1er Cru les Vergelesses'),
       (153, 'St Joseph'),
       (154, 'St. Chinian'),
       (155, 'St. Emilion'),
       (156, 'St. Joseph'),
       (157, 'St. Julien'),
       (158, 'St. Nicolas de Bourgueil'),
       (159, 'St. Veran'),
       (160, 'Terrasses du Larzac'),
       (161, 'Vin de France'),
       (162, 'Vino de Mesa'),
       (163, 'Viré-Clessé'),
       (164, 'Volnay'),
       (165, 'Volnay 1er Cru les Caillerets'),
       (166, 'Volnay 1er Cru les Champans'),
       (167, 'Volnay 1er Cru les Chevrets'),
       (168, 'Volnay 1er Cru les Fremiets'),
       (169, 'Volnay 1er Cru les Santenots'),
       (170, 'Volnay 1er Cru Roncerets'),
       (171, 'Vouvray')
"""

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
COLA_PDF_Filename,
@TariffDiscount,
@WineName
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
AE_Record_Id=if(@AE_Record_Id = '', NULL, @AE_Record_Id),
TariffDiscount=if(@TariffDiscount = '', NULL, @TariffDiscount),
WineName=if(@WineName = '', NULL, @WineName)
;
"""

    # Select statement to retrieve producer's wines ordered by producer then descending dates
    _legacy_wines_by_producer_sql_fmt = """
SELECT WineId
     , ProducerName
     , ProducerDescription
     , ProducerCode
     , YearEstablished
  FROM chw.LegacyWineMaster{suffix}
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
;
"""

    # Format string to create insert statement to create Wines records
    # from LegacyWineMaster records
    # where parameter suffix must be supplied.
    # used by get_insert_wines_from_legacy method
    _insert_wines_from_legacy_sql_fmt = """
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
    WineCountryId,
    WineRegionId,
    WineSubregionId,
    WineAppellationId,
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
    LkupWClr.WineColorId,
    LkupWT.WineTypeId,
    if(CertifiedOrganic = 'certified organic', TRUE, FALSE),
    LWM.Varietals,
    if(LWM.ABV IS NULL, -1, LWM.ABV),
    LkupWCntry.WineCountryId,
    LkupWR.WineRegionId,
    LkupWSR.WineSubregionId,
    LkupWA.WineAppellationId,
    WP.ProducerId,
    LWM.BottlesPerCase,
    -1,
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
FROM LegacyWineMaster{suffix} LWM
INNER JOIN LookupWineTypes LkupWT
  ON LWM.StillSparklingFortified = LkupWT.WineType
INNER JOIN LookupWineColors LkupWClr
  ON LWM.Color = LkupWClr.WineColor
INNER JOIN LookupWineCountries LkupWCntry
  ON LWM.Country = LkupWCntry.CountryName
LEFT JOIN LookupWineRegions LkupWR
  ON LWM.Region = LkupWR.RegionName
LEFT JOIN LookupWineSubregions LkupWSR
  ON LWM.Subregion = LkupWSR.SubregionName
LEFT JOIN LookupWineAppellations LkupWA
  ON LWM.Appellation = LkupWA.AppellationName
LEFT JOIN Producers WP
  ON LWM.ProducerName = WP.Name
;
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

    @classmethod
    def get_legacy_wines_by_producer_sql(cls, params):
        """
        Returns the sql statement to select the producer columns from
        the LegacyWineMaster table with the given suffix.

        params is a dictionary with a suffix key to be inserted
        into the sql format string being returned.
        """
        return cls._legacy_wines_by_producer_sql_fmt.format(**params)

    @classmethod
    def get_insert_wines_from_legacy_sql(cls, params):
        """
        Returns the sql statement to insert records in the Wines table from
        the LegacyWineMaster table with the given suffix.

        params is a dictionary with a suffix key to be inserted
        into the sql format string being returned.
        """
        return cls._insert_wines_from_legacy_sql_fmt.format(**params)
