"""
################################################################################
  chw_sql_wine.py
################################################################################

This module provides SQL statements for working with the CHW wine database tables.

Python naming convention reminder note: single underscore prefix class names are
for "private" internal use and should not be considered part of the public API.

=============== ================================================================
Created on      October 7, 2026
--------------- ----------------------------------------------------------------
author(s)       Michael Jay Lippert
--------------- ----------------------------------------------------------------
Copyright       (c) 2025-present Michael Jay Lippert
                MIT License (see https://opensource.org/licenses/MIT)
=============== ================================================================
"""

# Standard library imports
from enum import IntEnum, auto

# Third party imports

# Local application imports


class CHW_SQL_Wine:
    """
    CHW_SQL_Wine provides the sql statements used by to operate on the mariadb
    chw database wine tables and other entities.

    As sql statements can be long and span many lines encapsulating them in
    this class helps organize them and allows the code where they are used to
    be more easily read.
    """

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
VALUES (-1,'Unknown',          'unknown', 'ml',      0.0,    0, '--'),
       (1, 'Bottle 750ml',     'bottle',  'ml',    750.0,  750, '750ml'),
       (2, 'Magnum 1.5 Liter', 'bottle',  'Liter',   1.5, 1500, '1.5 Liter (Magnum)'),
       (3, 'Bottle 375ml',     'bottle',  'ml',    375.0,  375, '375ml'),
       (4, 'BiB 3 Liter',      'BiB',     'Liter',   3.0, 3000, '3 Liter'),
       (5, 'BiB 6 Liter',      'BiB',     'Liter',   6.0, 6000, '6 Liter'),
       (6, 'Can 250ml',        'can',     'ml',    250.0,  250, '250ml'),
       (7, 'Can 500ml',        'can',     'ml',    500.0,  500, '500ml')
"""

    insert_lookup_wine_countries_sql = """
INSERT IGNORE INTO LookupWineCountries
VALUES (1, 'France'), (2, 'Germany'), (3, 'Greece'), (4, 'Italy'), (5, 'Spain'), (6, 'USA')
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

    insert_lookup_us_states_sql = """
INSERT IGNORE INTO LookupUSStates
VALUES ('AL', 'Alabama', 'Ala.'),
       ('AK', 'Alaska', 'Alaska'),
       ('AZ', 'Arizona', 'Ariz.'),
       ('AR', 'Arkansas', 'Ark.'),
       ('CA', 'California', 'Calif.'),
       ('CO', 'Colorado', 'Color.'),
       ('CT', 'Connecticut', 'Conn.'),
       ('DE', 'Delaware', 'Del.'),
       ('FL', 'Florida', 'Fla.'),
       ('GA', 'Georgia', 'Ga.'),
       ('HI', 'Hawaii', 'Hawaii'),
       ('ID', 'Idaho', 'Idaho'),
       ('IL', 'Illinois', 'Ill.'),
       ('IN', 'Indiana', 'Ind.'),
       ('IA', 'Iowa', 'Iowa'),
       ('KS', 'Kansas', 'Kan.'),
       ('KY', 'Kentucky', 'Ky.'),
       ('LA', 'Louisiana', 'La.'),
       ('ME', 'Maine', 'Maine'),
       ('MD', 'Maryland', 'Md.'),
       ('MA', 'Massachusetts', 'Mass.'),
       ('MI', 'Michigan', 'Mich.'),
       ('MN', 'Minnesota', 'Minn.'),
       ('MS', 'Mississippi', 'Miss.'),
       ('MO', 'Missouri', 'Mo.'),
       ('MT', 'Montana', 'Mont.'),
       ('NE', 'Nebraska', 'Neb.'),
       ('NV', 'Nevada', 'Nev.'),
       ('NH', 'New Hampshire', 'N.H.'),
       ('NJ', 'New Jersey', 'N.J.'),
       ('NM', 'New Mexico', 'N.M.'),
       ('NY', 'New York', 'N.Y.'),
       ('NC', 'North Carolina', 'N.C.'),
       ('ND', 'North Dakota', 'N.D.'),
       ('OH', 'Ohio', 'Ohio'),
       ('OK', 'Oklahoma', 'Okla.'),
       ('OR', 'Oregon', 'Ore.'),
       ('PA', 'Pennsylvania', 'Pa.'),
       ('RI', 'Rhode Island', 'R.I.'),
       ('SC', 'South Carolina', 'S.C.'),
       ('SD', 'South Dakota', 'S.Dak.'),
       ('TN', 'Tennessee', 'Tenn.'),
       ('TX', 'Texas', 'Tex.'),
       ('UT', 'Utah', 'Utah'),
       ('VT', 'Vermont', 'V.T.'),
       ('VA', 'Virginia', 'Va.'),
       ('WA', 'Washington', 'Wash.'),
       ('WV', 'West Virginia', 'W.Va.'),
       ('WI', 'Wisconsin', 'Wis.'),
       ('WY', 'Wyoming', 'Wyo.'),
       ('DC', 'District of Columbia', 'D.C.'),
       ('GU', 'Guam', 'Guam'),
       ('MH', 'Marshall Islands', 'M.I.'),
       ('MP', 'Northern Mariana Island', 'CNMI'),
       ('PR', 'Puerto Rico', 'P.R. or PUR'),
       ('VI', 'Virgin Islands', 'V.I.')
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
WineCode,
@WineName,
@EndOfWine,
@Vintage,
@EndOfVintage,
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
@BottleColor,
ShelfTalkerText,
TastingNotes,
Vinification,
TerroirVineyardPractices,
PressParagraph,
ProducerCode,
ProducerName,
ProducerDescription,
YearEstablished,
Exporter,
@LOA_Date,
LOA_Comment,
@Multiple_LOAs,
StatesAuthorized,
@StatesAuthConfirmationDate,
AR_BrandRegNo,
@AR_BrandRegExpDate,
CT_BrandRegNo,
@CT_BrandRegExpDate,
LA_BrandRegNo,
@LA_BrandRegExpDate,
MS_BrandRegNo,
@MS_BrandRegExpDate,
NJ_AssignedUPC,
NJ_BrandRegNo,
@NJ_BrandRegExpDate,
TX_BrandRegNo,
@TX_BrandRegDate,
BrandRegNotes,
Elysia_InternalId,
Elysia_WineName,
Elysia_UnitPack,
Elysia_AlcoholClass,
Elysia_AlcoholType,
Elysia_NY_Direct,
@LastPurchasePrice_PO,
@LastPurchaseDate_PO,
@LastPurchasePrice_AE,
@LastPurchase_AE_ImportDate,
PurchaseType,
@LPP_Change,
@TariffDiscount,
@EstArrival,
@Active,
@Available,
@Excluded,
@SoldOut,
@OnOrder,
@ComingSoon,
@ETA_Available,
@Closeout,
@WesternInventory_Cases,
@WesternInventory_Bottles,
@WesternInventory_SyncTimestamp,
@WesternInventory_UpdatedTimestamp,
PriceListSection,
PriceListNotes,
@FOBPrice,
@FOB_Change,
@FOB_MA,
@FOB_ARB,
ARB_Comment,
@NY_Wholesale,
@NY_MultiCasePrice1,
@NY_MultiCaseQty1,
@NY_MultiCasePrice2,
@NY_MultiCaseQty2,
@NY_MultiCasePrice3,
@NY_MultiCaseQty3,
@NJ_Wholesale,
@NJ_MultiCasePrice1,
@NJ_MultiCaseQty1,
@NJ_MultiCasePrice2,
@NJ_MultiCaseQty2,
@NJ_MultiCasePrice3,
@NJ_MultiCaseQty3,
@Exclude_NY,
@Exclude_NJ,
PriceNotes,
PricingSpecials,
@PricingNeedsReview,
@PricingChangeAnnounce,
@AE_Record_Id,
NY_CurrentPricing,
NJ_CurrentPricing,
MA_CurrentPricing,
FrontLabelFilename,
BackLabelFilename,
COLA_PDF_Filename,
LOA_PDF_Filename,
@CREATED,
@LASTUPDATED
)
SET
Vintage=if(@Vintage = 'NV', -1, @Vintage),
ABV=if(@ABV = '', NULL, @ABV),
BottleColor=if(@BottleColor = '', NULL, @BottleColor),
DateCreated=if(@CREATED = '', NULL, @CREATED),
LastUpdated=if(@LASTUPDATED = '', NULL, @LASTUPDATED),
LastPurchasePrice_PO=if(@LastPurchasePrice_PO = '', NULL, @LastPurchasePrice_PO),
LastPurchaseDate_PO=if(@LastPurchaseDate_PO = '', NULL, @LastPurchaseDate_PO),
LastPurchasePrice_AE=if(@LastPurchasePrice_AE = '', NULL, @LastPurchasePrice_AE),
LastPurchase_AE_ImportDate=if(@LastPurchase_AE_ImportDate = '', NULL, @LastPurchase_AE_ImportDate),
EstArrival=if(@EstArrival = '', NULL, @EstArrival),
WesternInventory_Cases=if(@WesternInventory_Cases = '', NULL, @WesternInventory_Cases),
WesternInventory_Bottles=if(@WesternInventory_Bottles = '', NULL, @WesternInventory_Bottles),
WesternInventory_SyncTimestamp=if(@WesternInventory_SyncTimestamp = '', NULL, @WesternInventory_SyncTimestamp),
WesternInventory_UpdatedTimestamp=if(@WesternInventory_UpdatedTimestamp = '', NULL, @WesternInventory_UpdatedTimestamp),
FOBPrice=if(@FOBPrice = '', NULL, @FOBPrice),
FOB_MA=if(@FOB_MA = '', NULL, @FOB_MA),
FOB_ARB=if(@FOB_ARB = '', NULL, @FOB_ARB),
NY_Wholesale=if(@NY_Wholesale = '', NULL, @NY_Wholesale),
NY_MultiCasePrice1=if(@NY_MultiCasePrice1 = '', NULL, @NY_MultiCasePrice1),
NY_MultiCaseQty1=if(@NY_MultiCaseQty1 = '', NULL, @NY_MultiCaseQty1),
NY_MultiCasePrice2=if(@NY_MultiCasePrice2 = '', NULL, @NY_MultiCasePrice2),
NY_MultiCaseQty2=if(@NY_MultiCaseQty2 = '', NULL, @NY_MultiCaseQty2),
NY_MultiCasePrice3=if(@NY_MultiCasePrice3 = '', NULL, @NY_MultiCasePrice3),
NY_MultiCaseQty3=if(@NY_MultiCaseQty3 = '', NULL, @NY_MultiCaseQty3),
NJ_Wholesale=if(@NJ_Wholesale = '', NULL, @NJ_Wholesale),
NJ_MultiCasePrice1=if(@NJ_MultiCasePrice1 = '', NULL, @NJ_MultiCasePrice1),
NJ_MultiCaseQty1=if(@NJ_MultiCaseQty1 = '', NULL, @NJ_MultiCaseQty1),
NJ_MultiCasePrice2=if(@NJ_MultiCasePrice2 = '', NULL, @NJ_MultiCasePrice2),
NJ_MultiCaseQty2=if(@NJ_MultiCaseQty2 = '', NULL, @NJ_MultiCaseQty2),
NJ_MultiCasePrice3=if(@NJ_MultiCasePrice3 = '', NULL, @NJ_MultiCasePrice3),
NJ_MultiCaseQty3=if(@NJ_MultiCaseQty3 = '', NULL, @NJ_MultiCaseQty3),
AE_Record_Id=if(@AE_Record_Id = '', NULL, @AE_Record_Id),
TariffDiscount=if(@TariffDiscount = '', NULL, @TariffDiscount),
WineName=if(@WineName = '', NULL, @WineName),
AR_BrandRegExpDate=if(@AR_BrandRegExpDate = '', NULL, @AR_BrandRegExpDate),
CT_BrandRegExpDate=if(@CT_BrandRegExpDate = '', NULL, @CT_BrandRegExpDate),
LA_BrandRegExpDate=if(@LA_BrandRegExpDate = '', NULL, @LA_BrandRegExpDate),
MS_BrandRegExpDate=if(@MS_BrandRegExpDate = '', NULL, @MS_BrandRegExpDate),
NJ_BrandRegExpDate=if(@NJ_BrandRegExpDate = '', NULL, @NJ_BrandRegExpDate),
TX_BrandRegDate=if(@TX_BrandRegDate = '', NULL, @TX_BrandRegDate),
StatesAuthConfirmationDate=if(@StatesAuthConfirmationDate = '', NULL, @StatesAuthConfirmationDate),
LOA_Date=if(@LOA_Date = '', NULL, @LOA_Date),
SoldOut=if(@SoldOut = '', FALSE, @SoldOut),
Excluded=if(@Excluded = '', FALSE, @Excluded),
OnOrder=if(@OnOrder = '', FALSE, @OnOrder),
Available=if(@Available = '', FALSE, @Available),
Active=if(@Active = '', FALSE, @Active),
Exclude_NY=if(@Exclude_NY = '', FALSE, @Exclude_NY),
Exclude_NJ=if(@Exclude_NJ = '', FALSE, @Exclude_NJ),
LPP_Change=if(@LPP_Change = '', FALSE, @LPP_Change),
FOB_Change=if(@FOB_Change = '', FALSE, @FOB_Change),
EndOfVintage=if(@EndOfVintage = '', FALSE, @EndOfVintage),
EndOfWine=if(@EndOfWine = '', FALSE, @EndOfWine),
ComingSoon=if(@ComingSoon = '', FALSE, @ComingSoon),
ETA_Available=if(@ETA_Available = '', FALSE, @ETA_Available),
Closeout=if(@Closeout = '', FALSE, @Closeout),
Multiple_LOAs=if(@Multiple_LOAs = '', FALSE, @Multiple_LOAs),
PricingNeedsReview=if(@PricingNeedsReview = '', FALSE, @PricingNeedsReview),
PricingChangeAnnounce=if(@PricingChangeAnnounce = '', FALSE, @PricingChangeAnnounce)
"""

    # Select statement to retrieve producer's wines ordered by producer then descending dates
    # Note: LastUpdated is not useful now as it is changed by the automated updating of Western Inventory
    class Col_legacy_wines_by_producer(IntEnum):
        WineId                     = 0
        ProducerCode               = auto()
        ProducerName               = auto()
        ProducerDescription        = auto()
        YearEstablished            = auto()
        Exporter                   = auto()
        LOA_Date                   = auto()
        LOA_Comment                = auto()
        Multiple_LOAs              = auto()
        StatesAuthorized           = auto()
        StatesAuthConfirmationDate = auto()

    _legacy_wines_by_producer_sql_fmt = """
SELECT WineId
     , ProducerCode
     , ProducerName
     , ProducerDescription
     , YearEstablished
     , Exporter
     , LOA_Date
     , LOA_Comment
     , Multiple_LOAs
     , StatesAuthorized
     , StatesAuthConfirmationDate
  FROM chw.LegacyWineMaster{suffix}
 ORDER BY ProducerCode ASC, DateCreated DESC, LastUpdated DESC
"""

    # Insert statement to create Producer record
    insert_producer_sql = """
INSERT INTO chw.Producers
    ( ProducerCode
    , Name
    , Description
    , YearEstablished
    , Exporter
    )
 VALUES (?, ?, ?, ?, ?)
"""

    # Insert statement to create ProducerLOA record
    insert_producer_loa_sql = """
INSERT INTO chw.ProducerLOAs
    ( ProducerId
    , LOA_Date
    , Comment
    , MultipleLOAs
    , StatesAuthorizationConfirmationDate
    )
 VALUES (?, ?, ?, ?, ?)
"""

    # Insert statement to create ProducerLOAAuthorizedState record
    insert_producer_loa_authorized_state_sql = """
INSERT INTO chw.ProducerLOAAuthorizedStates
    ( ProducerId
    , StatePostalAbbrev
    )
 VALUES (?, ?)
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

    # Format string for getting Wines from LegacyWineMaster
    # sorted by WineCode and then date created.
    class Col_legacy_wines_by_winecode(IntEnum):
        WineItemId               = 0
        WineCode                 = auto()
        COLA_TTB_ID              = auto()
        UPC                      = auto()
        FullName                 = auto()
        WineName                 = auto()
        WineColorId              = auto()
        WineTypeId               = auto()
        CertifiedOrganic         = auto()
        Varietals                = auto()
        WineCountryId            = auto()
        WineRegionId             = auto()
        WineSubregionId          = auto()
        WineAppellationId        = auto()
        ProducerId               = auto()
        ShelfTalkerText          = auto()
        TastingNotes             = auto()
        Vinification             = auto()
        TerroirVineyardPractices = auto()
        EndOfWine                = auto()
        PriceListSection         = auto()
        Created                  = auto()
        LastModified             = auto()

    _select_wines_from_legacy_sql_fmt = """
SELECT
    LWM.WineId WineItemId,
    LWM.WineCode,
    if(LWM.COLA_TTB_ID = '', 'Pending', LWM.COLA_TTB_ID) AS COLA_TTB_ID,
    if(LWM.UPC = '', NULL, LWM.UPC) AS UPC,
    LWM.FullName,
    LWM.WineName,
    LkupWClr.WineColorId,
    LkupWT.WineTypeId,
    if(CertifiedOrganic = 'certified organic', TRUE, FALSE) AS CertifiedOrganic,
    LWM.Varietals,
    LkupWCntry.WineCountryId,
    LkupWR.WineRegionId,
    LkupWSR.WineSubregionId,
    LkupWA.WineAppellationId,
    WP.ProducerId,
    LWM.ShelfTalkerText,
    LWM.TastingNotes,
    LWM.Vinification,
    LWM.TerroirVineyardPractices,
    LWM.EndOfWine,
    LWM.PriceListSection,
    if(LWM.DateCreated IS NULL, DATE(LWM.LastUpdated), LWM.DateCreated) AS Created,
    LWM.LastUpdated
FROM LegacyWineMaster{suffix} LWM
INNER JOIN LookupWineTypes LkupWT
  ON LWM.StillSparklingFortified = LkupWT.WineType
INNER JOIN LookupWineColors LkupWClr
  ON LWM.Color = LkupWClr.WineColor
INNER JOIN LookupWineCountries LkupWCntry
  ON LWM.Country = LkupWCntry.CountryName
INNER JOIN LookupCaseUnits LkupCsU
  ON LWM.BottleSize = LkupCsU.LegacyBottleSize
LEFT JOIN LookupWineRegions LkupWR
  ON LWM.Region = LkupWR.RegionName
LEFT JOIN LookupWineSubregions LkupWSR
  ON LWM.Subregion = LkupWSR.SubregionName
LEFT JOIN LookupWineAppellations LkupWA
  ON LWM.Appellation = LkupWA.AppellationName
LEFT JOIN Producers WP
  ON LWM.ProducerCode = WP.ProducerCode
ORDER BY LWM.WineCode ASC, LWM.DateCreated DESC, LWM.LastUpdated DESC
"""

    # Insert statement to create Wine record
    insert_wine_sql = """
INSERT INTO chw.Wines
    ( WineCode
    , COLA_TTB_ID
    , UPC
    , WineName
    , WineColorId
    , WineTypeId
    , CertifiedOrganic
    , Varietals
    , WineCountryId
    , WineRegionId
    , WineSubregionId
    , WineAppellationId
    , ProducerId
    , ShelfTalkerText
    , TastingNotes
    , Vinification
    , TerroirVineyardPractices
    , EndOfWine
    , PriceListSection
    , Created
    , CreatedBy
    , LastModified
    , LastModifiedBy
    )
 VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'Legacy', ?, 'Legacy')
"""

    # Insert statement to create Wines_LegacyWineMaster record
    insert_wine_legacywine_sql = """
INSERT INTO chw.Wines_LegacyWineMaster
    ( WineId
    , LegacyWineId
    )
 VALUES (?, ?)
"""

    # Format string to create insert statement to create WineComplianceInfo records
    # from LegacyWineMaster records
    # where parameter suffix must be supplied.
    # used by get_insert_winecomplianceinfo_from_legacy method
    _insert_winecomplianceinfo_from_legacy_sql_fmt = """
INSERT INTO WineComplianceInfo
(
    WineId,
    AR_BrandRegNo,
    AR_BrandRegExpDate,
    CT_BrandRegNo,
    CT_BrandRegExpDate,
    LA_BrandRegNo,
    LA_BrandRegExpDate,
    MS_BrandRegNo,
    MS_BrandRegExpDate,
    NJ_AssignedUPC,
    NJ_BrandRegNo,
    NJ_BrandRegExpDate,
    TX_BrandRegNo,
    TX_BrandRegDate,
    BrandRegNotes,
    Elysia_InternalId,
    Elysia_WineName,
    Elysia_UnitPack,
    Elysia_AlcoholClass,
    Elysia_AlcoholType,
    Elysia_NY_Direct
)
SELECT
    W.WineId,
    LWM.AR_BrandRegNo,
    LWM.AR_BrandRegExpDate,
    LWM.CT_BrandRegNo,
    LWM.CT_BrandRegExpDate,
    LWM.LA_BrandRegNo,
    LWM.LA_BrandRegExpDate,
    LWM.MS_BrandRegNo,
    LWM.MS_BrandRegExpDate,
    LWM.NJ_AssignedUPC,
    LWM.NJ_BrandRegNo,
    LWM.NJ_BrandRegExpDate,
    LWM.TX_BrandRegNo,
    LWM.TX_BrandRegDate,
    LWM.BrandRegNotes,
    LWM.Elysia_InternalId,
    LWM.Elysia_WineName,
    LWM.Elysia_UnitPack,
    LWM.Elysia_AlcoholClass,
    LWM.Elysia_AlcoholType,
    LWM.Elysia_NY_Direct
FROM LegacyWineMaster{suffix} LWM
INNER JOIN Wines_LegacyWineMaster W_LWM
  ON LWM.WineId = W_LWM.LegacyWineId
INNER JOIN Wines W
  ON W.WineId = W_LWM.WineId
"""

    # Format string for getting WineItems from LegacyWineMaster
    # sorted by date created.
    class Col_legacy_wineitems(IntEnum):
        WineItemId       = 0
        AccountingItemNo = auto()
        FullName         = auto()
        WineId           = auto()
        Vintage          = auto()
        ABV              = auto()
        UnitsPerCase     = auto()
        CaseUnitId       = auto()
        BottleColor      = auto()
        PressParagraph   = auto()
        PriceListNotes   = auto()
        Active           = auto()
        Available        = auto()
        SoldOut          = auto()
        OnOrder          = auto()
        ComingSoon       = auto()
        ETA_Available    = auto()
        Closeout         = auto()
        EndOfVintage     = auto()
        AE_Record_Id     = auto()
        Created          = auto()
        LastModified     = auto()

    _select_wineitems_from_legacy_sql_fmt = """
SELECT
    LWM.WineId WineItemId,
    LWM.AccountingItemNo,
    LWM.FullName,
    W.WineId,
    LWM.Vintage,
    LWM.ABV,
    LWM.BottlesPerCase UnitsPerCase,
    LkupCsU.CaseUnitId,
    LWM.BottleColor,
    LWM.PressParagraph,
    LWM.PriceListNotes,
    LWM.Active,
    LWM.Available,
    LWM.SoldOut,
    LWM.OnOrder,
    LWM.ComingSoon,
    LWM.ETA_Available,
    LWM.Closeout,
    LWM.EndOfVintage,
    LWM.AE_Record_Id,
    if(LWM.DateCreated IS NULL, DATE(LWM.LastUpdated), LWM.DateCreated) AS Created,
    LWM.LastUpdated
FROM LegacyWineMaster{suffix} LWM
LEFT JOIN LookupCaseUnits LkupCsU
  ON LWM.BottleSize = LkupCsU.LegacyBottleSize
LEFT JOIN Wines W
  ON LWM.WineCode = W.WineCode
ORDER BY LWM.WineCode ASC, LWM.DateCreated DESC, LWM.LastUpdated DESC
"""

    # Insert statement to create WineItem record
    insert_wineitem_sql = """
INSERT INTO chw.WineItems
    ( WineItemId
    , AccountingItemNo
    , FullName
    , WineId
    , Vintage
    , ABV
    , UnitsPerCase
    , CaseUnitId
    , BottleColor
    , PressParagraph
    , PriceListNotes
    , Active
    , Available
    , SoldOut
    , OnOrder
    , ComingSoon
    , ETA_Available
    , Closeout
    , EndOfVintage
    , AE_Record_Id
    , Created
    , CreatedBy
    , LastModified
    , LastModifiedBy
    )
 VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'Legacy', ?, 'Legacy')
"""

    # Format string to create insert statement to create Wines records
    # from LegacyWineMaster records
    # where parameter suffix must be supplied.
    # used by get_insert_wines_from_legacy method
    _insert_wineitems_from_legacy_sql_fmt = """
INSERT INTO WineItems
    ( WineItemId
    , AccountingItemNo
    , FullName
    , WineId
    , Vintage
    , ABV
    , UnitsPerCase
    , CaseUnitId
    , BottleColor
    , PressParagraph
    , PriceListNotes
    , Active
    , Available
    , SoldOut
    , OnOrder
    , ComingSoon
    , ETA_Available
    , Closeout
    , EndOfVintage
    , AE_Record_Id
    , Created
    , CreatedBy
    , LastModified
    , LastModifiedBy
    )
SELECT
    LWM.WineId,
    LWM.AccountingItemNo,
    LWM.FullName,
    W.WineId,
    LWM.Vintage,
    LWM.ABV,
    LWM.BottlesPerCase,
    LkupCsU.CaseUnitId,
    LWM.BottleColor,
    LWM.PressParagraph,
    LWM.PriceListNotes,
    LWM.Active,
    LWM.Available,
    LWM.SoldOut,
    LWM.OnOrder,
    LWM.ComingSoon,
    LWM.ETA_Available,
    LWM.Closeout,
    LWM.EndOfVintage,
    LWM.AE_Record_Id,
    if(LWM.DateCreated IS NULL, DATE(LWM.LastUpdated), LWM.DateCreated),
    'Legacy',
    LWM.LastUpdated,
    'Legacy'
FROM LegacyWineMaster{suffix} LWM
LEFT JOIN LookupCaseUnits LkupCsU
  ON LWM.BottleSize = LkupCsU.LegacyBottleSize
LEFT JOIN Wines W
  ON LWM.WineCode = W.WineCode
"""

    # Format string to create insert statement to create WesternInventory records
    # from LegacyWineMaster records
    # where parameter suffix must be supplied.
    # used by get_insert_westerninventory_from_legacy method
    _insert_westerninventory_from_legacy_sql_fmt = """
INSERT INTO WesternInventory
(
    WineItemId,
    Cases,
    Bottles,
    SyncTimestamp,
    UpdatedTimestamp
)
SELECT
    LWM.WineId,
    if(LWM.WesternInventory_Cases IS NULL, 0, LWM.WesternInventory_Cases),
    if(LWM.WesternInventory_Bottles IS NULL, 0, LWM.WesternInventory_Bottles),
    if(LWM.WesternInventory_SyncTimestamp IS NULL, NOW(), LWM.WesternInventory_SyncTimestamp),
    LWM.WesternInventory_UpdatedTimestamp
FROM LegacyWineMaster{suffix} LWM
"""

    # Format string to create insert statement to create WinePurchases records
    # from LegacyWineMaster records
    # where parameter suffix must be supplied.
    # used by get_insert_winepurchases_from_legacy method
    # NOTE: Currently handle and convert integer discount percentages to fractional values
    _insert_winepurchases_from_legacy_sql_fmt = """
INSERT INTO WinePurchases
(
    WineItemId,
    PurchaseDate_PO,
    PurchasePrice_PO,
    PurchasePrice_AE,
    PurchaseType,
    TariffDiscount
)
SELECT
    LWM.WineId,
    LWM.LastPurchaseDate_PO,
    LWM.LastPurchasePrice_PO,
    LWM.LastPurchasePrice_AE,
    LWM.PurchaseType,
    if(LWM.TariffDiscount >= 1, LWM.TariffDiscount / 100, LWM.TariffDiscount)
FROM LegacyWineMaster{suffix} LWM
WHERE LWM.LastPurchaseDate_PO IS NOT NULL
"""

    # Format string to create insert statement to create WinePricing records
    # from LegacyWineMaster records
    # where parameter suffix must be supplied.
    # used by get_insert_winepricing_from_legacy method
    _insert_winepricing_from_legacy_sql_fmt = """
INSERT INTO WinePricing
(
    WineItemId,
    FOBPrice,
    FOB_MA,
    FOB_ARB,
    ARB_Comment,
    PriceNotes,
    Specials,
    NeedsReview,
    ChangeAnnounce
)
SELECT
    LWM.WineId,
    LWM.FOBPrice,
    LWM.FOB_MA,
    LWM.FOB_ARB,
    LWM.ARB_Comment,
    LWM.PriceNotes,
    LWM.PricingSpecials,
    LWM.PricingNeedsReview,
    LWM.PricingChangeAnnounce
FROM LegacyWineMaster{suffix} LWM
"""

    # Format string to create select statement to get wine wholesale pricing columns
    # from LegacyWineMaster records
    # where parameter suffix must be supplied.
    # used by get_select_winewholesalepricing_from_legacy method
    class Col_legacy_winewholesalepricing(IntEnum):
        WineItemId         = 0
        NY_Wholesale       = auto()
        NY_MultiCasePrice1 = auto()
        NY_MultiCaseQty1   = auto()
        NY_MultiCasePrice2 = auto()
        NY_MultiCaseQty2   = auto()
        NY_MultiCasePrice3 = auto()
        NY_MultiCaseQty3   = auto()
        NJ_Wholesale       = auto()
        NJ_MultiCasePrice1 = auto()
        NJ_MultiCaseQty1   = auto()
        NJ_MultiCasePrice2 = auto()
        NJ_MultiCaseQty2   = auto()
        NJ_MultiCasePrice3 = auto()
        NJ_MultiCaseQty3   = auto()
        Exclude_NY         = auto()
        Exclude_NJ         = auto()

    _select_winewholesalepricing_from_legacy_sql_fmt = """
SELECT
    LWM.WineId WineItemId,
    LWM.NY_Wholesale,
    LWM.NY_MultiCasePrice1,
    LWM.NY_MultiCaseQty1,
    LWM.NY_MultiCasePrice2,
    LWM.NY_MultiCaseQty2,
    LWM.NY_MultiCasePrice3,
    LWM.NY_MultiCaseQty3,
    LWM.NJ_Wholesale,
    LWM.NJ_MultiCasePrice1,
    LWM.NJ_MultiCaseQty1,
    LWM.NJ_MultiCasePrice2,
    LWM.NJ_MultiCaseQty2,
    LWM.NJ_MultiCasePrice3,
    LWM.NJ_MultiCaseQty3,
    LWM.Exclude_NY,
    LWM.Exclude_NJ
FROM LegacyWineMaster{suffix} LWM
"""

    # Insert statement to create WineWholesalePricing record
    insert_winewholesalepricing_sql = """
INSERT INTO chw.WineWholesalePricing
    ( WineItemId
    , StatePostalAbbrev
    , WholesalePrice
    )
 VALUES (?, ?, ?)
"""

    # Insert statement to create WineWholesalePricing record
    insert_winewholesalecasebreaks_sql = """
INSERT INTO chw.WineWholesaleCaseBreaks
    ( WineItemId
    , StatePostalAbbrev
    , CaseQty
    , Price
    )
 VALUES (?, ?, ?, ?)
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
    def get_select_wines_from_legacy_sql(cls, params):
        """
        Returns the sql statement to select records from the LegacyWineMaster
        table with the given suffix. The selection will contain the columns
        to be copied into the Wine table.

        params is a dictionary with a suffix key to be inserted
        into the sql format string being returned.
        """
        return cls._select_wines_from_legacy_sql_fmt.format(**params)

    @classmethod
    def get_insert_winecomplianceinfo_from_legacy_sql(cls, params):
        """
        Returns the sql statement to insert records in the WineComplianceInfo table
        from the LegacyWineMaster table with the given suffix.

        params is a dictionary with a suffix key to be inserted
        into the sql format string being returned.
        """
        return cls._insert_winecomplianceinfo_from_legacy_sql_fmt.format(**params)

    @classmethod
    def get_insert_wineitems_from_legacy_sql(cls, params):
        """
        Returns the sql statement to insert records in the WineItems table from
        the LegacyWineMaster table with the given suffix.

        params is a dictionary with a suffix key to be inserted
        into the sql format string being returned.
        """
        return cls._insert_wineitems_from_legacy_sql_fmt.format(**params)

    @classmethod
    def get_insert_westerninventory_from_legacy_sql(cls, params):
        """
        Returns the sql statement to insert records in the WesternInventory table from
        the LegacyWineMaster table with the given suffix.

        params is a dictionary with a suffix key to be inserted
        into the sql format string being returned.
        """
        return cls._insert_westerninventory_from_legacy_sql_fmt.format(**params)

    @classmethod
    def get_insert_winepurchases_from_legacy_sql(cls, params):
        """
        Returns the sql statement to insert records in the WinePurchases table from
        the LegacyWineMaster table with the given suffix.

        params is a dictionary with a suffix key to be inserted
        into the sql format string being returned.
        """
        return cls._insert_winepurchases_from_legacy_sql_fmt.format(**params)

    @classmethod
    def get_insert_winepricing_from_legacy_sql(cls, params):
        """
        Returns the sql statement to insert records in the WinePricing table from
        the LegacyWineMaster table with the given suffix.

        params is a dictionary with a suffix key to be inserted
        into the sql format string being returned.
        """
        return cls._insert_winepricing_from_legacy_sql_fmt.format(**params)

    @classmethod
    def get_select_winewholesalepricing_from_legacy_sql(cls, params):
        """
        Returns the sql statement to to get wine wholesale pricing columns from
        the LegacyWineMaster table with the given suffix.
        Col_legacy_winewholesalepricing is an enum of the selected columns

        params is a dictionary with a suffix key to be inserted
        into the sql format string being returned.
        """
        return cls._select_winewholesalepricing_from_legacy_sql_fmt.format(**params)
