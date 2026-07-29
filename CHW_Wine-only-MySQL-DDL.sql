
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

CREATE TABLE LegacyWineMaster_1218 (
                WineId INT NOT NULL,
                AccountingItemNo VARCHAR(11),
                NYPPItemNo VARCHAR(17),
                WesternItemNo VARCHAR(11),
                COLA_TTB_ID VARCHAR(15),
                UPC VARCHAR(13),
                FullName VARCHAR(114),
                Vintage SMALLINT,
                Color VARCHAR(5),
                StillSparklingFortified VARCHAR(9),
                CertifiedOrganic VARCHAR(19),
                Varietals VARCHAR(100),
                ABV DECIMAL(5,2),
                Country VARCHAR(7),
                Region VARCHAR(20),
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
                ProducerName VARCHAR(58),
                ProducerDescription TEXT(1269),
                ProducerCode CHAR(3),
                YearEstablished VARCHAR(27),
                Exporter VARCHAR(30),
                NJ_AssignedUPC VARCHAR(13),
                NJ_BrandRegNo VARCHAR(6),
                LastPurchasePrice DECIMAL(8,2),
                LastPurchaseDate DATE,
                DateCreated DATE,
                LastUpdated DATETIME,
                Excluded VARCHAR(24),
                SoldOut CHAR(1),
                PriceListSection VARCHAR(39),
                PriceListNotes VARCHAR(144),
                FOBPrice DECIMAL(8,2),
                FOB_MA DECIMAL(8,2),
                FOB_ARB DECIMAL(8,2),
                ARB_Comment VARCHAR(250),
                NY_Wholesale DECIMAL(8,2),
                NY_MultiCasePrice DECIMAL(8,2),
                NY_MultiCaseQty TINYINT,
                NJ_Wholesale DECIMAL(8,2),
                NJ_MultiCasePrice DECIMAL(8,2),
                NJ_MultiCaseQty TINYINT,
                PriceNotes VARCHAR(250),
                AE_Record_Id INT,
                NY_CurrentPricing VARCHAR(42),
                NJ_CurrentPricing VARCHAR(30),
                MA_CurrentPricing VARCHAR(29),
                FrontLabelFilename VARCHAR(86),
                BackLabelFilename VARCHAR(69),
                COLA_PDF_Filename VARCHAR(70),
                TariffDiscount TINYINT,
                WineName VARCHAR(86),
                PRIMARY KEY (WineId)
);

ALTER TABLE LegacyWineMaster_1218 MODIFY COLUMN Vintage SMALLINT COMMENT '4 digit year';

ALTER TABLE LegacyWineMaster_1218 MODIFY COLUMN Varietals VARCHAR(100) COMMENT 'Comma separated list of the grape varietals in the wine';

ALTER TABLE LegacyWineMaster_1218 MODIFY COLUMN ABV DECIMAL(5, 2) COMMENT 'Alcohol % by volume';

ALTER TABLE LegacyWineMaster_1218 MODIFY COLUMN CaseUnitType VARCHAR(7) COMMENT 'Bottle, Can, BiB';

ALTER TABLE LegacyWineMaster_1218 MODIFY COLUMN LastPurchasePrice DECIMAL(8, 2) COMMENT 'Price/case paid to producer in Euros';

ALTER TABLE LegacyWineMaster_1218 MODIFY COLUMN SoldOut CHAR(1) COMMENT 'True(1)-sold out, False(0)-in stock';

ALTER TABLE LegacyWineMaster_1218 MODIFY COLUMN FOBPrice DECIMAL(8, 2) COMMENT 'Free on board (FOB) is the wine price for a case that includes all costs up to being lifted onto a ship.';

ALTER TABLE LegacyWineMaster_1218 MODIFY COLUMN FOB_MA DECIMAL(8, 2) COMMENT 'FOB in MA which the Arborway price is discounted from';

ALTER TABLE LegacyWineMaster_1218 MODIFY COLUMN FOB_ARB DECIMAL(8, 2) COMMENT 'discounted FOB price negotiated w/ Arborway';

ALTER TABLE LegacyWineMaster_1218 MODIFY COLUMN ARB_Comment VARCHAR(250) COMMENT 'Explanation for Arborway price when overridden from std discount';

ALTER TABLE LegacyWineMaster_1218 MODIFY COLUMN NY_Wholesale DECIMAL(8, 2) COMMENT '"wholesale" price that is price posted in NY';

ALTER TABLE LegacyWineMaster_1218 MODIFY COLUMN NJ_Wholesale DECIMAL(8, 2) COMMENT '"wholesale" price that is price posted in NJ';

ALTER TABLE LegacyWineMaster_1218 MODIFY COLUMN AE_Record_Id INTEGER COMMENT 'Account Edge record Id';


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
                Name VARCHAR(100) NOT NULL,
                Description TEXT(2000),
                ProducerCode CHAR(3),
                YearEstablished SMALLINT,
                PRIMARY KEY (ProducerId)
);

ALTER TABLE Producers COMMENT 'A wine producer';


CREATE UNIQUE INDEX producers_name_idx
 ON Producers
 ( Name );

CREATE TABLE Wines (
                WineId INT AUTO_INCREMENT NOT NULL,
                COLA_TTB_ID VARCHAR(15) DEFAULT 'Pending' NOT NULL,
                UPC VARCHAR(13),
                WineName VARCHAR(150),
                WineColorId TINYINT NOT NULL,
                WineTypeId TINYINT NOT NULL,
                CertifiedOrganic BOOLEAN DEFAULT 0 NOT NULL,
                Varietals VARCHAR(100),
                ABV DECIMAL(5,2) NOT NULL,
                WineCountryId TINYINT NOT NULL,
                WineRegionId TINYINT,
                WineSubregionId TINYINT,
                WineAppellationId SMALLINT,
                ProducerId INT NOT NULL,
                BottleColor VARCHAR(15),
                ShelfTalkerText TEXT(2000),
                TastingNotes TEXT(2000),
                Vinification TEXT(2000),
                TerroirVineyardPractices TEXT(2000),
                PressParagraph TEXT(6000),
                Exporter VARCHAR(50),
                Created DATETIME NOT NULL,
                CreatedBy VARCHAR(32) NOT NULL,
                LastModified DATETIME NOT NULL,
                LastModifiedBy VARCHAR(32) NOT NULL,
                PRIMARY KEY (WineId)
);

ALTER TABLE Wines MODIFY COLUMN COLA_TTB_ID VARCHAR(15) COMMENT 'Either the TTB ID or ''Pending''';

ALTER TABLE Wines MODIFY COLUMN Varietals VARCHAR(100) COMMENT 'Comma separated list of the grape varietals in the wine';

ALTER TABLE Wines MODIFY COLUMN ABV DECIMAL(5, 2) COMMENT 'Alcohol % by volume';

ALTER TABLE Wines MODIFY COLUMN CreatedBy VARCHAR(32) COMMENT 'User who created this record';

ALTER TABLE Wines MODIFY COLUMN LastModifiedBy VARCHAR(32) COMMENT 'User who last modified this record';


CREATE TABLE WineItems (
                WineItemId INT AUTO_INCREMENT NOT NULL,
                AccountingItemNo VARCHAR(15) NOT NULL,
                FullName VARCHAR(150) NOT NULL,
                WineId INT NOT NULL,
                Vintage SMALLINT NOT NULL,
                UnitsPerCase SMALLINT NOT NULL,
                CaseUnitId TINYINT NOT NULL,
                PRIMARY KEY (WineItemId)
);

ALTER TABLE WineItems COMMENT 'A given wine may have multiple variations, differing by vintage or also packaging (6pk vs 12pk)';

ALTER TABLE WineItems MODIFY COLUMN AccountingItemNo VARCHAR(15) COMMENT 'AccountEdge ID';

ALTER TABLE WineItems MODIFY COLUMN Vintage SMALLINT COMMENT '4 digit year, -1 for NV (no vintage)';

ALTER TABLE WineItems MODIFY COLUMN UnitsPerCase SMALLINT COMMENT 'Units of wine include various size bottles, boxes and cans
Retail sales are sometimes by case and sometimes by unit';


CREATE TABLE WinePricing (
                WineItemId INT NOT NULL,
                Available BOOLEAN DEFAULT 0 NOT NULL,
                SoldOut BOOLEAN DEFAULT 0 NOT NULL,
                PriceListSection VARCHAR(50),
                PriceListNotes VARCHAR(160),
                FOBPrice DECIMAL(8,2),
                FOB_MA DECIMAL(8,2),
                FOB_ARB DECIMAL(8,2) DEFAULT FOBPrice,
                ARB_Comment VARCHAR(250),
                NY_Wholesale DECIMAL(8,2),
                NY_MultiCasePrice DECIMAL(8,2),
                NY_MultiCaseQty TINYINT,
                NJ_Wholesale DECIMAL(8,2),
                NJ_MultiCasePrice DECIMAL(8,2),
                NJ_MultiCaseQty TINYINT,
                PriceNotes VARCHAR(250),
                PRIMARY KEY (WineItemId)
);

ALTER TABLE WinePricing COMMENT 'Interim table to gather existing wine pricing fields';

ALTER TABLE WinePricing MODIFY COLUMN Available BOOLEAN COMMENT 'If a wine is not available it should be excluded from the list of wines for sale (True(1)-available, False(0)-excluded)';

ALTER TABLE WinePricing MODIFY COLUMN SoldOut BOOLEAN COMMENT 'True(1)-sold out, False(0)-in stock';

ALTER TABLE WinePricing MODIFY COLUMN FOBPrice DECIMAL(8, 2) COMMENT 'case price for distributors, null if not set yet for new wine';

ALTER TABLE WinePricing MODIFY COLUMN FOB_ARB DECIMAL(8, 2) COMMENT 'discounted FOB price negotiated w/ Arborway';

ALTER TABLE WinePricing MODIFY COLUMN NY_Wholesale DECIMAL(8, 2) COMMENT 'NY distributor price for retailers';

ALTER TABLE WinePricing MODIFY COLUMN NY_MultiCasePrice DECIMAL(8, 2) COMMENT 'NY multi case break retailer price';

ALTER TABLE WinePricing MODIFY COLUMN NY_MultiCaseQty TINYINT COMMENT 'NY min # of cases to get multi case price';

ALTER TABLE WinePricing MODIFY COLUMN NJ_Wholesale DECIMAL(8, 2) COMMENT 'NJ distributor price for retailers';

ALTER TABLE WinePricing MODIFY COLUMN NJ_MultiCasePrice DECIMAL(8, 2) COMMENT 'NJ multi case break retailer price';

ALTER TABLE WinePricing MODIFY COLUMN NJ_MultiCaseQty TINYINT COMMENT 'NJ min # of cases to get multi case price';


CREATE TABLE NJ_Distribution (
                WineId INT NOT NULL,
                NJ_BrandRegNo VARCHAR(6) NOT NULL,
                NJ_AssignedUPC VARCHAR(13),
                PRIMARY KEY (WineId)
);

ALTER TABLE NJ_Distribution COMMENT 'Information for distribution in NJ
- Compliance info
  - Brand registration
  - Price posting
- pricing in NJ';

ALTER TABLE NJ_Distribution MODIFY COLUMN NJ_AssignedUPC VARCHAR(13) COMMENT 'NJ assigned UPC value if wine doesn''t have one';


CREATE TABLE Producers_LegacyWineMaster (
                ProducerId INT NOT NULL,
                WineId INT NOT NULL,
                ConversionNotes VARCHAR(250),
                PRIMARY KEY (ProducerId, WineId)
);

ALTER TABLE Producers_LegacyWineMaster MODIFY COLUMN ConversionNotes VARCHAR(250) COMMENT 'Notes about creating the producer from the legacy wine records';


CREATE TABLE WinePurchases (
                WineItemId INT NOT NULL,
                PurchaseDate DATE NOT NULL,
                PurchasePrice DECIMAL(8,2) NOT NULL,
                TariffDiscount DECIMAL(3,2),
                PRIMARY KEY (WineItemId, PurchaseDate)
);

ALTER TABLE WinePurchases COMMENT 'Track costs for purchases of a wine';

ALTER TABLE WinePurchases MODIFY COLUMN PurchasePrice DECIMAL(8, 2) COMMENT 'Exporter/Producer''s price, for a case of the wine in Euros, for the purchase on this date';

ALTER TABLE WinePurchases MODIFY COLUMN TariffDiscount DECIMAL(3, 2) COMMENT 'Discount % from the Producer on this purchase  to share tariff cost. null unconfirmed, 0 confirmed no discount';


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

ALTER TABLE Producers_LegacyWineMaster ADD CONSTRAINT legacywinemaster_1106_producers_legacywinemaster_fk
FOREIGN KEY (WineId)
REFERENCES LegacyWineMaster_1218 (WineId)
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

ALTER TABLE NJ_Distribution ADD CONSTRAINT wines_nj_distribution_fk
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
