
CREATE TABLE LookupUSStates (
                StatePostalAbbrev CHAR(2) NOT NULL,
                StateFullName VARCHAR(30) NOT NULL,
                StateStdAbbrev VARCHAR(15) NOT NULL,
                PRIMARY KEY (StatePostalAbbrev)
);

ALTER TABLE LookupUSStates MODIFY COLUMN StatePostalAbbrev CHAR(2) COMMENT '2 character US State abbreviation';


CREATE TABLE LookupCaseUnits (
                CaseUnitId TINYINT AUTO_INCREMENT NOT NULL,
                Name VARCHAR(30) NOT NULL,
                UnitType VARCHAR(15) DEFAULT 'bottle' NOT NULL,
                VolumeUnitsOnLabel VARCHAR(15) DEFAULT 'ml' NOT NULL,
                VolumeInLabelUnits DECIMAL(6,2) NOT NULL,
                VolumeInMilliliters INT DEFAULT 750 NOT NULL,
                LegacyBottleSize VARCHAR(18) NOT NULL,
                PRIMARY KEY (CaseUnitId)
);

ALTER TABLE LookupCaseUnits MODIFY COLUMN Name VARCHAR(30) COMMENT 'Composite description of the Unit, e.g. Bottle 750ml, Can 20oz, BiB 500ml';

ALTER TABLE LookupCaseUnits MODIFY COLUMN UnitType VARCHAR(15) COMMENT 'Type of unit: bottle, can, BiB (bag in box)';

ALTER TABLE LookupCaseUnits MODIFY COLUMN VolumeUnitsOnLabel VARCHAR(15) COMMENT 'Volume units name (e.g ml, Liter) shown on label, and in name.';

ALTER TABLE LookupCaseUnits MODIFY COLUMN VolumeInMilliliters INTEGER COMMENT 'Volume in this unit in milliliters';

ALTER TABLE LookupCaseUnits MODIFY COLUMN LegacyBottleSize VARCHAR(18) COMMENT 'For join to create wine record from LegacyWineMaster, delete when no longer needed';


CREATE UNIQUE INDEX lookupcaseunits_legacybottlesize_idx
 ON LookupCaseUnits
 ( LegacyBottleSize );

CREATE TABLE LookupWineCountries (
                WineCountryId TINYINT AUTO_INCREMENT NOT NULL,
                CountryName VARCHAR(20) NOT NULL,
                PRIMARY KEY (WineCountryId)
);


CREATE UNIQUE INDEX lookupwinecountries_countryname_idx
 ON LookupWineCountries
 ( CountryName );

CREATE TABLE LegacyWineMaster_0824 (
                WineId INT NOT NULL,
                AccountingItemNo VARCHAR(11),
                NYPPItemNo VARCHAR(17),
                WesternItemNo VARCHAR(11),
                COLA_TTB_ID VARCHAR(15),
                UPC VARCHAR(13),
                FullName VARCHAR(114),
                WineCode CHAR(5),
                WineName VARCHAR(86),
                EndOfWine BOOLEAN NOT NULL,
                Vintage SMALLINT,
                EndOfVintage BOOLEAN NOT NULL,
                Color VARCHAR(5),
                StillSparklingFortified VARCHAR(9),
                CertifiedOrganic VARCHAR(19),
                Varietals VARCHAR(125),
                ABV DECIMAL(5,2),
                Country VARCHAR(7),
                Region VARCHAR(25),
                Subregion VARCHAR(20),
                Appellation VARCHAR(58),
                CaseUnitType VARCHAR(7),
                BottleSize VARCHAR(18),
                BottlesPerCase TINYINT,
                BottleColor VARCHAR(6),
                ShelfTalkerText TEXT(1030),
                TastingNotes TEXT(1248),
                Vinification TEXT(1146),
                TerroirVineyardPractices TEXT(1359),
                PressParagraph TEXT(4660),
                ProducerCode CHAR(3),
                ProducerName VARCHAR(58),
                ProducerDescription TEXT(1783),
                YearEstablished VARCHAR(27),
                Exporter VARCHAR(41),
                LOA_Date DATE,
                LOA_Comment VARCHAR(125),
                Multiple_LOAs BOOLEAN NOT NULL,
                StatesAuthorized VARCHAR(168),
                StatesAuthConfirmationDate DATE,
                AR_BrandRegNo VARCHAR(16),
                AR_BrandRegExpDate DATE,
                CT_BrandRegNo VARCHAR(12),
                CT_BrandRegExpDate DATE,
                LA_BrandRegNo VARCHAR(16),
                LA_BrandRegExpDate DATE,
                MS_BrandRegNo VARCHAR(16),
                MS_BrandRegExpDate DATE,
                NJ_AssignedUPC VARCHAR(13),
                NJ_BrandRegNo VARCHAR(6),
                NJ_BrandRegExpDate DATE,
                TX_BrandRegNo VARCHAR(16),
                TX_BrandRegDate DATE,
                BrandRegNotes VARCHAR(250),
                Elysia_InternalId VARCHAR(7),
                Elysia_WineName VARCHAR(120),
                Elysia_UnitPack VARCHAR(50),
                Elysia_AlcoholClass VARCHAR(13),
                Elysia_AlcoholType VARCHAR(24),
                Elysia_NY_Direct VARCHAR(37),
                LastPurchasePrice_PO DECIMAL(8,2),
                LastPurchaseDate_PO DATE,
                LastPurchasePrice_AE DECIMAL(8,2),
                LastPurchase_AE_ImportDate DATE,
                PurchaseType VARCHAR(8),
                LPP_Change BOOLEAN NOT NULL,
                TariffDiscount TINYINT,
                EstArrival DATE,
                Active BOOLEAN NOT NULL,
                Available BOOLEAN NOT NULL,
                Excluded BOOLEAN NOT NULL,
                SoldOut BOOLEAN NOT NULL,
                OnOrder BOOLEAN NOT NULL,
                ComingSoon BOOLEAN NOT NULL,
                Closeout BOOLEAN NOT NULL,
                WesternInventory_Cases SMALLINT,
                WesternInventory_Bottles TINYINT,
                WesternInventory_SyncTimestamp DATETIME,
                WesternInventory_UpdatedTimestamp DATETIME,
                PriceListSection VARCHAR(48),
                PriceListNotes VARCHAR(144),
                FOBPrice DECIMAL(8,2),
                FOB_Change BOOLEAN NOT NULL,
                FOB_MA DECIMAL(8,2),
                FOB_ARB DECIMAL(8,2),
                ARB_Comment VARCHAR(250),
                NY_Wholesale DECIMAL(8,2),
                NY_MultiCasePrice1 DECIMAL(8,2),
                NY_MultiCaseQty1 TINYINT,
                NY_MultiCasePrice2 DECIMAL(8,2),
                NY_MultiCaseQty2 TINYINT,
                NY_MultiCasePrice3 DECIMAL(8,2),
                NY_MultiCaseQty3 TINYINT,
                NJ_Wholesale DECIMAL(8,2),
                NJ_MultiCasePrice1 DECIMAL(8,2),
                NJ_MultiCaseQty1 TINYINT,
                NJ_MultiCasePrice2 DECIMAL(8,2),
                NJ_MultiCaseQty2 TINYINT,
                NJ_MultiCasePrice3 DECIMAL(8,2),
                NJ_MultiCaseQty3 TINYINT,
                Exclude_NY BOOLEAN NOT NULL,
                Exclude_NJ BOOLEAN NOT NULL,
                PriceNotes TEXT(2000),
                PricingSpecials VARCHAR(250),
                PricingNeedsReview BOOLEAN NOT NULL,
                PricingChangeAnnounce BOOLEAN NOT NULL,
                AE_Record_Id INT,
                NY_CurrentPricing VARCHAR(42),
                NJ_CurrentPricing VARCHAR(30),
                MA_CurrentPricing VARCHAR(29),
                FrontLabelFilename VARCHAR(86),
                BackLabelFilename VARCHAR(69),
                COLA_PDF_Filename VARCHAR(70),
                LOA_PDF_Filename VARCHAR(85),
                DateCreated DATE,
                LastUpdated DATETIME,
                PRIMARY KEY (WineId)
);

ALTER TABLE LegacyWineMaster_0824 MODIFY COLUMN WineCode CHAR(5) COMMENT 'Code that identifies the Wine this is an instance of. 3 char producer code + 2 chars for specific wine';

ALTER TABLE LegacyWineMaster_0824 MODIFY COLUMN EndOfWine BOOLEAN COMMENT 'Additional Wine can no longer be purchased';

ALTER TABLE LegacyWineMaster_0824 MODIFY COLUMN Vintage SMALLINT COMMENT '4 digit year';

ALTER TABLE LegacyWineMaster_0824 MODIFY COLUMN EndOfVintage BOOLEAN COMMENT 'Additional Wine of this vintage can no longer be purchased';

ALTER TABLE LegacyWineMaster_0824 MODIFY COLUMN Varietals VARCHAR(125) COMMENT 'Comma separated list of the grape varietals in the wine';

ALTER TABLE LegacyWineMaster_0824 MODIFY COLUMN ABV DECIMAL(5, 2) COMMENT 'Alcohol % by volume';

ALTER TABLE LegacyWineMaster_0824 MODIFY COLUMN CaseUnitType VARCHAR(7) COMMENT 'Bottle, Can, BiB';

ALTER TABLE LegacyWineMaster_0824 MODIFY COLUMN StatesAuthorized VARCHAR(168) COMMENT '2 char state abbrevs separated by newlines';

ALTER TABLE LegacyWineMaster_0824 MODIFY COLUMN Elysia_InternalId VARCHAR(7) COMMENT 'Assigned by Elysia after adding item, unique to wine+vintage';

ALTER TABLE LegacyWineMaster_0824 MODIFY COLUMN Elysia_WineName VARCHAR(120) COMMENT 'wine name + vintage';

ALTER TABLE LegacyWineMaster_0824 MODIFY COLUMN Elysia_NY_Direct VARCHAR(37) COMMENT 'FOB & cs brk prices in 1 field separated by commas';

ALTER TABLE LegacyWineMaster_0824 MODIFY COLUMN LastPurchasePrice_PO DECIMAL(8, 2) COMMENT 'Price/case paid to producer in Euros';

ALTER TABLE LegacyWineMaster_0824 MODIFY COLUMN LastPurchasePrice_AE DECIMAL(8, 2) COMMENT 'Price/case paid to producer in Euros converted to $ when paid in by Accounting';

ALTER TABLE LegacyWineMaster_0824 MODIFY COLUMN PurchaseType VARCHAR(8) COMMENT 'New Wine, New Vtg, Restock';

ALTER TABLE LegacyWineMaster_0824 MODIFY COLUMN LPP_Change BOOLEAN COMMENT 'Last purchase PO price changed from the one before';

ALTER TABLE LegacyWineMaster_0824 MODIFY COLUMN TariffDiscount TINYINT COMMENT '% of price discount by producer for tariffs';

ALTER TABLE LegacyWineMaster_0824 MODIFY COLUMN SoldOut BOOLEAN COMMENT 'True(1)-sold out, False(0)-in stock';

ALTER TABLE LegacyWineMaster_0824 MODIFY COLUMN WesternInventory_SyncTimestamp TIMESTAMP COMMENT 'TS when the western cases/bottles was last synced with Western API';

ALTER TABLE LegacyWineMaster_0824 MODIFY COLUMN WesternInventory_UpdatedTimestamp TIMESTAMP COMMENT 'TS when the sync w/ Western changed the # of bottles/cases';

ALTER TABLE LegacyWineMaster_0824 MODIFY COLUMN FOBPrice DECIMAL(8, 2) COMMENT 'Free on board (FOB) is the wine price for a case that includes all costs up to being lifted onto a ship.';

ALTER TABLE LegacyWineMaster_0824 MODIFY COLUMN FOB_MA DECIMAL(8, 2) COMMENT 'FOB in MA which the Arborway price is discounted from';

ALTER TABLE LegacyWineMaster_0824 MODIFY COLUMN FOB_ARB DECIMAL(8, 2) COMMENT 'discounted FOB price negotiated w/ Arborway';

ALTER TABLE LegacyWineMaster_0824 MODIFY COLUMN ARB_Comment VARCHAR(250) COMMENT 'Explanation for Arborway price when overridden from std discount';

ALTER TABLE LegacyWineMaster_0824 MODIFY COLUMN NY_Wholesale DECIMAL(8, 2) COMMENT '"wholesale" price that is price posted in NY';

ALTER TABLE LegacyWineMaster_0824 MODIFY COLUMN NJ_Wholesale DECIMAL(8, 2) COMMENT '"wholesale" price that is price posted in NJ';

ALTER TABLE LegacyWineMaster_0824 MODIFY COLUMN Exclude_NY BOOLEAN COMMENT 'Wine may not be sold in NY';

ALTER TABLE LegacyWineMaster_0824 MODIFY COLUMN Exclude_NJ BOOLEAN COMMENT 'Wine may not be sold in NJ';

ALTER TABLE LegacyWineMaster_0824 MODIFY COLUMN AE_Record_Id INTEGER COMMENT 'Account Edge record Id';


CREATE INDEX legacywinemaster_winecode_idx
 ON LegacyWineMaster_0824
 ( WineCode ASC );

CREATE INDEX legacywinemaster_producercode_idx
 ON LegacyWineMaster_0824
 ( ProducerCode ASC );

CREATE TABLE LookupWineSubregions (
                WineSubregionId TINYINT AUTO_INCREMENT NOT NULL,
                SubregionName VARCHAR(30) NOT NULL,
                PRIMARY KEY (WineSubregionId)
);


CREATE UNIQUE INDEX lookupwinesubregions_subregionname_idx
 ON LookupWineSubregions
 ( SubregionName );

CREATE TABLE LookupWineTypes (
                WineTypeId TINYINT AUTO_INCREMENT NOT NULL,
                WineType VARCHAR(10) NOT NULL,
                PRIMARY KEY (WineTypeId)
);

ALTER TABLE LookupWineTypes COMMENT 'Still, Sparkling or Fortified';

ALTER TABLE LookupWineTypes MODIFY COLUMN WineType VARCHAR(10) COMMENT 'Still, Sparkling or Fortified';


CREATE UNIQUE INDEX lookupwinetypes_winetype_idx
 ON LookupWineTypes
 ( WineType );

CREATE TABLE LookupWineRegions (
                WineRegionId TINYINT AUTO_INCREMENT NOT NULL,
                RegionName VARCHAR(30) NOT NULL,
                PRIMARY KEY (WineRegionId)
);


CREATE UNIQUE INDEX lookupwineregions_regionname_idx
 ON LookupWineRegions
 ( RegionName );

CREATE TABLE LookupWineColors (
                WineColorId TINYINT AUTO_INCREMENT NOT NULL,
                WineColor VARCHAR(10) NOT NULL,
                PRIMARY KEY (WineColorId)
);

ALTER TABLE LookupWineColors MODIFY COLUMN WineColor VARCHAR(10) COMMENT 'White, Red or Rosé';


CREATE UNIQUE INDEX lookupwinecolors_winecolor_idx
 ON LookupWineColors
 ( WineColor );

CREATE TABLE LookupWineAppellations (
                WineAppellationId SMALLINT NOT NULL,
                AppellationName VARCHAR(80) NOT NULL,
                PRIMARY KEY (WineAppellationId)
);


CREATE UNIQUE INDEX lookupwineappellations_appellationname_idx
 ON LookupWineAppellations
 ( AppellationName );

CREATE TABLE Producers (
                ProducerId INT AUTO_INCREMENT NOT NULL,
                ProducerCode CHAR(3),
                Name VARCHAR(100) NOT NULL,
                ShortName VARCHAR(100) NOT NULL,
                Description TEXT(2000),
                YearEstablished SMALLINT,
                Exporter VARCHAR(50),
                PRIMARY KEY (ProducerId)
);

ALTER TABLE Producers COMMENT 'A wine producer';

ALTER TABLE Producers MODIFY COLUMN ShortName VARCHAR(100) COMMENT 'Producer Name included in full wine name';


CREATE UNIQUE INDEX producers_name_idx
 ON Producers
 ( Name );

CREATE UNIQUE INDEX akproducercode
 ON Producers
 ( ProducerCode );

CREATE TABLE ProducerLOAs (
                ProducerId INT NOT NULL,
                LOA_Date DATE NOT NULL,
                Comment VARCHAR(250),
                MultipleLOAs BOOLEAN NOT NULL,
                StatesAuthorizationConfirmationDate DATE,
                PRIMARY KEY (ProducerId)
);

ALTER TABLE ProducerLOAs MODIFY COLUMN MultipleLOAs BOOLEAN COMMENT 'There is more than 1 LOA, look on server';


CREATE TABLE ProducerLOAAuthorizedStates (
                ProducerId INT NOT NULL,
                StatePostalAbbrev CHAR(2) NOT NULL,
                PRIMARY KEY (ProducerId, StatePostalAbbrev)
);

ALTER TABLE ProducerLOAAuthorizedStates MODIFY COLUMN StatePostalAbbrev CHAR(2) COMMENT '2 character US State abbreviation';


CREATE TABLE Wines (
                WineId INT AUTO_INCREMENT NOT NULL,
                COLA_TTB_ID VARCHAR(15) DEFAULT 'Pending' NOT NULL,
                UPC VARCHAR(13),
                WineCode CHAR(5) NOT NULL,
                WineName VARCHAR(150) NOT NULL,
                WineColorId TINYINT NOT NULL,
                WineTypeId TINYINT NOT NULL,
                CertifiedOrganic BOOLEAN DEFAULT 0 NOT NULL,
                Varietals VARCHAR(100),
                WineCountryId TINYINT NOT NULL,
                WineRegionId TINYINT,
                WineSubregionId TINYINT,
                WineAppellationId SMALLINT,
                ProducerId INT NOT NULL,
                ShelfTalkerText TEXT(2000),
                TastingNotes TEXT(2000),
                Vinification TEXT(2000),
                TerroirVineyardPractices TEXT(2000),
                EndOfWine BOOLEAN DEFAULT FALSE NOT NULL,
                PriceListSection VARCHAR(50),
                Created DATETIME NOT NULL,
                CreatedBy VARCHAR(32) NOT NULL,
                LastModified DATETIME NOT NULL,
                LastModifiedBy VARCHAR(32) NOT NULL,
                PRIMARY KEY (WineId)
);

ALTER TABLE Wines MODIFY COLUMN COLA_TTB_ID VARCHAR(15) COMMENT 'Either the TTB ID or ''Pending''';

ALTER TABLE Wines MODIFY COLUMN WineCode CHAR(5) COMMENT 'Unique alternate key, 3 char producer code + 2 char to specify wine';

ALTER TABLE Wines MODIFY COLUMN Varietals VARCHAR(100) COMMENT 'Comma separated list of the grape varietals in the wine';

ALTER TABLE Wines MODIFY COLUMN EndOfWine BOOLEAN COMMENT 'Additional Wine can no longer be purchased';

ALTER TABLE Wines MODIFY COLUMN CreatedBy VARCHAR(32) COMMENT 'User who created this record';

ALTER TABLE Wines MODIFY COLUMN LastModifiedBy VARCHAR(32) COMMENT 'User who last modified this record';


CREATE UNIQUE INDEX akwinecode
 ON Wines
 ( WineCode );

CREATE TABLE WineItems (
                WineItemId INT AUTO_INCREMENT NOT NULL,
                AccountingItemNo VARCHAR(15) NOT NULL,
                FullName VARCHAR(150) NOT NULL,
                WineId INT NOT NULL,
                Vintage SMALLINT NOT NULL,
                ABV DECIMAL(5,2) NOT NULL,
                UnitsPerCase SMALLINT NOT NULL,
                CaseUnitId TINYINT NOT NULL,
                BottleColor VARCHAR(15),
                PressParagraph TEXT(6000),
                PriceListNotes VARCHAR(160),
                Active BOOLEAN NOT NULL,
                Available BOOLEAN NOT NULL,
                SoldOut BOOLEAN NOT NULL,
                OnOrder BOOLEAN NOT NULL,
                ComingSoon BOOLEAN NOT NULL,
                Closeout BOOLEAN NOT NULL,
                EndOfVintage BOOLEAN DEFAULT FALSE NOT NULL,
                AE_Record_Id INT,
                PRIMARY KEY (WineItemId)
);

ALTER TABLE WineItems COMMENT 'A given wine may have multiple variations, differing by vintage or also packaging (6pk vs 12pk)';

ALTER TABLE WineItems MODIFY COLUMN AccountingItemNo VARCHAR(15) COMMENT 'AccountEdge ID';

ALTER TABLE WineItems MODIFY COLUMN Vintage SMALLINT COMMENT '4 digit year, -1 for NV (no vintage)';

ALTER TABLE WineItems MODIFY COLUMN ABV DECIMAL(5, 2) COMMENT 'Alcohol % by volume';

ALTER TABLE WineItems MODIFY COLUMN UnitsPerCase SMALLINT COMMENT 'Units of wine include various size bottles, boxes and cans
Retail sales are sometimes by case and sometimes by unit';

ALTER TABLE WineItems MODIFY COLUMN Available BOOLEAN COMMENT 'If a wine is not available it should be excluded from the list of wines for sale (True(1)-available, False(0)-excluded)';

ALTER TABLE WineItems MODIFY COLUMN SoldOut BOOLEAN COMMENT 'True(1)-sold out, False(0)-in stock';

ALTER TABLE WineItems MODIFY COLUMN EndOfVintage BOOLEAN COMMENT 'Additional Wine of this vintage can no longer be purchased';

ALTER TABLE WineItems MODIFY COLUMN AE_Record_Id INTEGER COMMENT 'AccountEdge record Id for this wine sku';


CREATE TABLE WinePricing (
                WineItemId INT NOT NULL,
                FOBPrice DECIMAL(8,2),
                FOB_MA DECIMAL(8,2),
                FOB_ARB DECIMAL(8,2) DEFAULT FOBPrice,
                ARB_Comment VARCHAR(250),
                PriceNotes VARCHAR(250),
                Specials VARCHAR(250),
                NeedsReview BOOLEAN NOT NULL,
                ChangeAnnounce BOOLEAN NOT NULL,
                PRIMARY KEY (WineItemId)
);

ALTER TABLE WinePricing COMMENT 'Interim table to gather existing wine pricing fields';

ALTER TABLE WinePricing MODIFY COLUMN FOBPrice DECIMAL(8, 2) COMMENT 'case price for distributors, null if not set yet for new wine';

ALTER TABLE WinePricing MODIFY COLUMN FOB_ARB DECIMAL(8, 2) COMMENT 'discounted FOB price negotiated w/ Arborway';


CREATE TABLE WineWholesalePricing (
                WineItemId INT NOT NULL,
                StatePostalAbbrev CHAR(2) NOT NULL,
                WholesalePrice DECIMAL(8,2) NOT NULL,
                PRIMARY KEY (WineItemId, StatePostalAbbrev)
);

ALTER TABLE WineWholesalePricing MODIFY COLUMN StatePostalAbbrev CHAR(2) COMMENT '2 character US State abbreviation';

ALTER TABLE WineWholesalePricing MODIFY COLUMN WholesalePrice DECIMAL(8, 2) COMMENT 'State distributor price for retailers';


CREATE TABLE WineWholesaleCaseBreaks (
                WineItemId INT NOT NULL,
                StatePostalAbbrev CHAR(2) NOT NULL,
                CaseQty TINYINT NOT NULL,
                Price DECIMAL(8,2) NOT NULL,
                PRIMARY KEY (WineItemId, StatePostalAbbrev, CaseQty)
);

ALTER TABLE WineWholesaleCaseBreaks MODIFY COLUMN StatePostalAbbrev CHAR(2) COMMENT '2 character US State abbreviation';

ALTER TABLE WineWholesaleCaseBreaks MODIFY COLUMN CaseQty TINYINT COMMENT 'Number of cases to purchase to get the case break price';


CREATE TABLE WineComplianceInfo (
                WineId INT NOT NULL,
                AR_BrandRegNo VARCHAR(16),
                AR_BrandRegExpDate DATE,
                CT_BrandRegNo VARCHAR(12),
                CT_BrandRegExpDate DATE,
                LA_BrandRegNo VARCHAR(16),
                LA_BrandRegExpDate DATE,
                MS_BrandRegNo VARCHAR(16),
                MS_BrandRegExpDate DATE,
                NJ_AssignedUPC VARCHAR(13),
                NJ_BrandRegNo VARCHAR(6),
                NJ_BrandRegExpDate DATE,
                TX_BrandRegNo VARCHAR(16),
                TX_BrandRegDate DATE,
                BrandRegNotes VARCHAR(250),
                Elysia_InternalId VARCHAR(7),
                Elysia_WineName VARCHAR(120),
                Elysia_UnitPack VARCHAR(50),
                Elysia_AlcoholClass VARCHAR(13),
                Elysia_AlcoholType VARCHAR(24),
                Elysia_NY_Direct VARCHAR(37),
                PRIMARY KEY (WineId)
);

ALTER TABLE WineComplianceInfo COMMENT 'This news to be reworked but is all the various compliance
info stored in the legacy wine master
- Compliance info is state specific:
  - Brand registration
  - Price posting';

ALTER TABLE WineComplianceInfo MODIFY COLUMN NJ_AssignedUPC VARCHAR(13) COMMENT 'NJ assigned UPC value if wine doesn''t have one';


CREATE TABLE Producers_LegacyWineMaster (
                ProducerId INT NOT NULL,
                WineId INT NOT NULL,
                ConversionNotes VARCHAR(250),
                PRIMARY KEY (ProducerId, WineId)
);

ALTER TABLE Producers_LegacyWineMaster MODIFY COLUMN ConversionNotes VARCHAR(250) COMMENT 'Notes about creating the producer from the legacy wine records';


CREATE TABLE WinePurchases (
                WineItemId INT NOT NULL,
                PurchaseDate_PO DATE NOT NULL,
                PurchasePrice_PO DECIMAL(8,2) NOT NULL,
                PurchasePrice_AE DECIMAL(8,2),
                PurchaseType VARCHAR(8),
                TariffDiscount DECIMAL(3,2),
                PRIMARY KEY (WineItemId, PurchaseDate_PO)
);

ALTER TABLE WinePurchases COMMENT 'Track costs for purchases of a wine';

ALTER TABLE WinePurchases MODIFY COLUMN PurchasePrice_PO DECIMAL(8, 2) COMMENT 'Exporter/Producer''s price, for a case of the wine in Euros, for the purchase on this date';

ALTER TABLE WinePurchases MODIFY COLUMN PurchasePrice_AE DECIMAL(8, 2) COMMENT 'Purchase price in US dollars after conversion in the Account Edge system';

ALTER TABLE WinePurchases MODIFY COLUMN PurchaseType VARCHAR(8) COMMENT 'New Wine, New Vtg, Restock';

ALTER TABLE WinePurchases MODIFY COLUMN TariffDiscount DECIMAL(3, 2) COMMENT 'Discount % from the Producer on this purchase  to share tariff cost. null unconfirmed, 0 confirmed no discount';


ALTER TABLE WineWholesalePricing ADD CONSTRAINT lookupusstates_winewholesalepricing_fk
FOREIGN KEY (StatePostalAbbrev)
REFERENCES LookupUSStates (StatePostalAbbrev)
ON DELETE NO ACTION
ON UPDATE NO ACTION;

ALTER TABLE ProducerLOAAuthorizedStates ADD CONSTRAINT lookupusstates_producerloaauthorizedstates_fk
FOREIGN KEY (StatePostalAbbrev)
REFERENCES LookupUSStates (StatePostalAbbrev)
ON DELETE NO ACTION
ON UPDATE NO ACTION;

ALTER TABLE WineItems ADD CONSTRAINT lookupcaseunits_wineitems_fk
FOREIGN KEY (CaseUnitId)
REFERENCES LookupCaseUnits (CaseUnitId)
ON DELETE NO ACTION
ON UPDATE NO ACTION;

ALTER TABLE Wines ADD CONSTRAINT lookupwinecountries_wines_fk
FOREIGN KEY (WineCountryId)
REFERENCES LookupWineCountries (WineCountryId)
ON DELETE NO ACTION
ON UPDATE NO ACTION;

ALTER TABLE Producers_LegacyWineMaster ADD CONSTRAINT legacywinemaster_0824_producers_legacywinemaster_fk
FOREIGN KEY (WineId)
REFERENCES LegacyWineMaster_0824 (WineId)
ON DELETE NO ACTION
ON UPDATE NO ACTION;

ALTER TABLE Wines ADD CONSTRAINT lookupwinesubregions_wines_fk
FOREIGN KEY (WineSubregionId)
REFERENCES LookupWineSubregions (WineSubregionId)
ON DELETE SET NULL
ON UPDATE NO ACTION;

ALTER TABLE Wines ADD CONSTRAINT lookupwinetypes_wines_fk
FOREIGN KEY (WineTypeId)
REFERENCES LookupWineTypes (WineTypeId)
ON DELETE NO ACTION
ON UPDATE NO ACTION;

ALTER TABLE Wines ADD CONSTRAINT lookupwineregions_wines_fk
FOREIGN KEY (WineRegionId)
REFERENCES LookupWineRegions (WineRegionId)
ON DELETE SET NULL
ON UPDATE NO ACTION;

ALTER TABLE Wines ADD CONSTRAINT lookupwinecolors_wines_fk
FOREIGN KEY (WineColorId)
REFERENCES LookupWineColors (WineColorId)
ON DELETE NO ACTION
ON UPDATE NO ACTION;

ALTER TABLE Wines ADD CONSTRAINT lookupwineappellations_wines_fk
FOREIGN KEY (WineAppellationId)
REFERENCES LookupWineAppellations (WineAppellationId)
ON DELETE SET NULL
ON UPDATE NO ACTION;

ALTER TABLE Producers_LegacyWineMaster ADD CONSTRAINT producers_producers_legacywinemaster_fk
FOREIGN KEY (ProducerId)
REFERENCES Producers (ProducerId)
ON DELETE NO ACTION
ON UPDATE NO ACTION;

ALTER TABLE Wines ADD CONSTRAINT producers_wines_fk
FOREIGN KEY (ProducerId)
REFERENCES Producers (ProducerId)
ON DELETE NO ACTION
ON UPDATE NO ACTION;

ALTER TABLE ProducerLOAs ADD CONSTRAINT producers_producerloas_fk
FOREIGN KEY (ProducerId)
REFERENCES Producers (ProducerId)
ON DELETE NO ACTION
ON UPDATE NO ACTION;

ALTER TABLE ProducerLOAAuthorizedStates ADD CONSTRAINT producerloas_producerloaauthorizedstates_fk
FOREIGN KEY (ProducerId)
REFERENCES ProducerLOAs (ProducerId)
ON DELETE NO ACTION
ON UPDATE NO ACTION;

ALTER TABLE WineComplianceInfo ADD CONSTRAINT wines_nj_distribution_fk
FOREIGN KEY (WineId)
REFERENCES Wines (WineId)
ON DELETE NO ACTION
ON UPDATE NO ACTION;

ALTER TABLE WineItems ADD CONSTRAINT wines_wineitems_fk
FOREIGN KEY (WineId)
REFERENCES Wines (WineId)
ON DELETE NO ACTION
ON UPDATE NO ACTION;

ALTER TABLE WinePurchases ADD CONSTRAINT wineitems_winepurchases_fk
FOREIGN KEY (WineItemId)
REFERENCES WineItems (WineItemId)
ON DELETE NO ACTION
ON UPDATE NO ACTION;

ALTER TABLE WinePricing ADD CONSTRAINT wineitems_winepricing_fk
FOREIGN KEY (WineItemId)
REFERENCES WineItems (WineItemId)
ON DELETE NO ACTION
ON UPDATE NO ACTION;

ALTER TABLE WineWholesalePricing ADD CONSTRAINT winepricing_winewholesalepricing_fk
FOREIGN KEY (WineItemId)
REFERENCES WinePricing (WineItemId)
ON DELETE NO ACTION
ON UPDATE NO ACTION;

ALTER TABLE WineWholesaleCaseBreaks ADD CONSTRAINT winewholesalepricing_winewholesalecasebreaks_fk
FOREIGN KEY (StatePostalAbbrev, WineItemId)
REFERENCES WineWholesalePricing (StatePostalAbbrev, WineItemId)
ON DELETE NO ACTION
ON UPDATE NO ACTION;
