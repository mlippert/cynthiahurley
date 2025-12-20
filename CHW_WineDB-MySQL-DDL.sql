
CREATE TABLE LookupWineAppellations (
                WineAppellationId SMALLINT NOT NULL,
                AppellationName VARCHAR(80) NOT NULL,
                PRIMARY KEY (WineAppellationId)
);


CREATE UNIQUE INDEX lookupwineappellations_appellationname_idx
 ON LookupWineAppellations
 ( AppellationName );

CREATE TABLE LookupWineSubregions (
                WineSubregionId TINYINT AUTO_INCREMENT NOT NULL,
                SubregionName VARCHAR(30) NOT NULL,
                PRIMARY KEY (WineSubregionId)
);


CREATE UNIQUE INDEX lookupwinesubregions_subregionname_idx
 ON LookupWineSubregions
 ( SubregionName );

CREATE TABLE LookupWineRegions (
                WineRegionId TINYINT AUTO_INCREMENT NOT NULL,
                RegionName VARCHAR(30) NOT NULL,
                PRIMARY KEY (WineRegionId)
);


CREATE UNIQUE INDEX lookupwineregions_regionname_idx
 ON LookupWineRegions
 ( RegionName );

CREATE TABLE LookupWineCountries (
                WineCountryId TINYINT AUTO_INCREMENT NOT NULL,
                CountryName VARCHAR(20) NOT NULL,
                PRIMARY KEY (WineCountryId)
);


CREATE UNIQUE INDEX lookupwinecountries_countryname_idx
 ON LookupWineCountries
 ( CountryName );

CREATE TABLE LookupWineColors (
                WineColorId TINYINT AUTO_INCREMENT NOT NULL,
                WineColor VARCHAR(10) NOT NULL,
                PRIMARY KEY (WineColorId)
);

ALTER TABLE LookupWineColors MODIFY COLUMN WineColor VARCHAR(10) COMMENT 'White, Red or Rosé';


CREATE UNIQUE INDEX lookupwinecolors_winecolor_idx
 ON LookupWineColors
 ( WineColor );

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


CREATE TABLE Retailers (
                RetailerId INT AUTO_INCREMENT NOT NULL,
                Name VARCHAR(100) NOT NULL,
                Email VARCHAR(100),
                PRIMARY KEY (RetailerId)
);

ALTER TABLE Retailers COMMENT 'Retailers fullfil the email customers orders';


CREATE TABLE LegacyEmailOrders_1106 (
                EmailOrderId INT NOT NULL,
                OrderNumber VARCHAR(10),
                FirstDate DATE,
                FullName VARCHAR(69),
                LastName VARCHAR(26),
                CompanyAptNo VARCHAR(51),
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
                Retailer VARCHAR(33),
                Quantity VARCHAR(37),
                DelItems VARCHAR(88),
                Vintage SMALLINT,
                Quant2 VARCHAR(24),
                DelItem2 VARCHAR(106),
                Vintage2 SMALLINT,
                Quant3 VARCHAR(34),
                DelItem3 VARCHAR(71),
                Vintage3 SMALLINT,
                Quant4 VARCHAR(36),
                DelItem4 VARCHAR(73),
                Vintage4 SMALLINT,
                Quant5 VARCHAR(22),
                DelItem5 VARCHAR(70),
                Vintage5 SMALLINT,
                CustDetails TEXT(1153),
                PRIMARY KEY (EmailOrderId)
);

ALTER TABLE LegacyEmailOrders_1106 MODIFY COLUMN OrderNumber VARCHAR(10) COMMENT 'Accounting system''s order number that includes this order';

ALTER TABLE LegacyEmailOrders_1106 MODIFY COLUMN Subtotal DECIMAL(8, 2) COMMENT 'Subtotal of the wine order before S&H';

ALTER TABLE LegacyEmailOrders_1106 MODIFY COLUMN AdditionalCharges VARCHAR(120) COMMENT 'Describe charges that will be added to subtotal';


CREATE INDEX legacyemailorders_1106_fullname_idx
 ON LegacyEmailOrders_1106
 ( FullName );

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

CREATE TABLE LookupCCIssuers (
                CCIssuerId TINYINT AUTO_INCREMENT NOT NULL,
                Name VARCHAR(20) NOT NULL,
                ShortName VARCHAR(8) NOT NULL,
                PRIMARY KEY (CCIssuerId)
);

ALTER TABLE LookupCCIssuers MODIFY COLUMN Name VARCHAR(20) COMMENT 'Name of Issuer; Visa, MC, Discover, Amex, etc.';

ALTER TABLE LookupCCIssuers MODIFY COLUMN ShortName VARCHAR(8) COMMENT 'Abbreviation';


CREATE TABLE LookupCaseUnits (
                CaseUnitId TINYINT AUTO_INCREMENT NOT NULL,
                Name VARCHAR(30) NOT NULL,
                UnitType VARCHAR(15) DEFAULT 'bottle' NOT NULL,
                VolumeUnitsOnLabel VARCHAR(15) DEFAULT 'ml' NOT NULL,
                VolumeInLabelUnits DECIMAL(6,2) NOT NULL,
                VolumeInMilliliters INT DEFAULT 750 NOT NULL,
                PRIMARY KEY (CaseUnitId)
);

ALTER TABLE LookupCaseUnits MODIFY COLUMN Name VARCHAR(30) COMMENT 'Composite description of the Unit, e.g. Bottle 750ml, Can 20oz, BiB 500ml';

ALTER TABLE LookupCaseUnits MODIFY COLUMN UnitType VARCHAR(15) COMMENT 'Type of unit: bottle, can, BiB (bag in box)';

ALTER TABLE LookupCaseUnits MODIFY COLUMN VolumeUnitsOnLabel VARCHAR(15) COMMENT 'Volume units name (e.g ml, Liter) shown on label, and in name.';

ALTER TABLE LookupCaseUnits MODIFY COLUMN VolumeInMilliliters INTEGER COMMENT 'Volume in this unit in milliliters';


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

CREATE TABLE Producers_LegacyWineMaster (
                ProducerId INT NOT NULL,
                WineId INT NOT NULL,
                ConversionNotes VARCHAR(250),
                PRIMARY KEY (ProducerId, WineId)
);

ALTER TABLE Producers_LegacyWineMaster MODIFY COLUMN ConversionNotes VARCHAR(250) COMMENT 'Notes about creating the producer from the legacy wine records';


CREATE TABLE Distributors (
                DistributorId INT AUTO_INCREMENT NOT NULL,
                Name VARCHAR(100) NOT NULL,
                Email VARCHAR(200) NOT NULL,
                PRIMARY KEY (DistributorId)
);

ALTER TABLE Distributors COMMENT 'The distributor is responsible for getting the order to the email customer';


CREATE TABLE Addresses (
                AddressId INT AUTO_INCREMENT NOT NULL,
                Street VARCHAR(150) NOT NULL,
                Street2 VARCHAR(150),
                City VARCHAR(100) NOT NULL,
                State VARCHAR(100) NOT NULL,
                PostalCode VARCHAR(30) NOT NULL,
                PRIMARY KEY (AddressId)
);

ALTER TABLE Addresses MODIFY COLUMN Street2 VARCHAR(150) COMMENT 'optional 2nd Street line for address';

ALTER TABLE Addresses MODIFY COLUMN PostalCode VARCHAR(30) COMMENT 'zipcode in USA';


CREATE TABLE Wines (
                WineId INT AUTO_INCREMENT NOT NULL,
                AccountingItemNo VARCHAR(15) NOT NULL,
                COLA_TTB_ID VARCHAR(15) DEFAULT 'Pending' NOT NULL,
                UPC VARCHAR(13),
                FullName VARCHAR(150) NOT NULL,
                WineName VARCHAR(150),
                Vintage SMALLINT,
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
                UnitsPerCase SMALLINT NOT NULL,
                CaseUnitId TINYINT NOT NULL,
                BottleColor VARCHAR(15),
                ShelfTalkerText TEXT(2000),
                TastingNotes TEXT(2000),
                Vinification TEXT(2000),
                TerroirVineyardPractices TEXT(2000),
                PressParagraph TEXT(6000),
                Exporter VARCHAR(50),
                LastPurchasePrice DECIMAL(8,2),
                LastPurchaseDate DATE,
                Created DATETIME NOT NULL,
                CreatedBy VARCHAR(32) NOT NULL,
                LastModified DATETIME NOT NULL,
                LastModifiedBy VARCHAR(32) NOT NULL,
                PRIMARY KEY (WineId)
);

ALTER TABLE Wines MODIFY COLUMN AccountingItemNo VARCHAR(15) COMMENT 'AccountEdge ID';

ALTER TABLE Wines MODIFY COLUMN COLA_TTB_ID VARCHAR(15) COMMENT 'Either the TTB ID or ''Pending''';

ALTER TABLE Wines MODIFY COLUMN Vintage SMALLINT COMMENT '4 digit year, -1 for NV (no vintage)';

ALTER TABLE Wines MODIFY COLUMN Varietals VARCHAR(100) COMMENT 'Comma separated list of the grape varietals in the wine';

ALTER TABLE Wines MODIFY COLUMN ABV DECIMAL(5, 2) COMMENT 'Alcohol % by volume';

ALTER TABLE Wines MODIFY COLUMN UnitsPerCase SMALLINT COMMENT 'Units of wine include various size bottles, boxes and cans
Retail sales are sometimes by case and sometimes by unit';

ALTER TABLE Wines MODIFY COLUMN CaseUnitId TINYINT COMMENT 'Type of unit in a case of this wine';

ALTER TABLE Wines MODIFY COLUMN LastPurchasePrice DECIMAL(8, 2) COMMENT 'Price paid to exporter in euros for a case';

ALTER TABLE Wines MODIFY COLUMN LastPurchaseDate DATE COMMENT 'Date of last purchase from the exporter';

ALTER TABLE Wines MODIFY COLUMN CreatedBy VARCHAR(32) COMMENT 'User who created this record';

ALTER TABLE Wines MODIFY COLUMN LastModifiedBy VARCHAR(32) COMMENT 'User who last modified this record';


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


CREATE TABLE WinePricing (
                WineId INT NOT NULL,
                Available BOOLEAN DEFAULT 0 NOT NULL,
                SoldOut BOOLEAN DEFAULT 0 NOT NULL,
                PriceListSection VARCHAR(50),
                PriceListNotes VARCHAR(80),
                FOBPrice DECIMAL(8,2),
                FOB_MA DECIMAL(8,2),
                FOB_ARB DECIMAL(8,2) DEFAULT FOBPrice,
                ARB_Comment VARCHAR(250),
                NY_Wholesale DECIMAL(8,2),
                NY_MultiCasePrice DECIMAL(8,2),
                NY_MultiCaseQty TINYINT,
                NJ_Wholesale DECIMAL(8,2),
                NJ_MultiCasePrice DECIMAL(8,2),
                NJ_MiltiCaseQty TINYINT,
                PriceNotes VARCHAR(250),
                PRIMARY KEY (WineId)
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

ALTER TABLE WinePricing MODIFY COLUMN NJ_MiltiCaseQty TINYINT COMMENT 'NJ min # of cases to get multi case price';


CREATE TABLE EmailCustomers (
                EmailCustomerId INT AUTO_INCREMENT NOT NULL,
                Title VARCHAR(20),
                GivenName VARCHAR(100) NOT NULL,
                Surname VARCHAR(100) NOT NULL,
                Suffix VARCHAR(15),
                Email VARCHAR(200) NOT NULL,
                Created DATETIME NOT NULL,
                CreatedBy VARCHAR(32) NOT NULL,
                LastModified DATETIME NOT NULL,
                LastModifiedBy VARCHAR(32) NOT NULL,
                PRIMARY KEY (EmailCustomerId)
);

ALTER TABLE EmailCustomers MODIFY COLUMN Title VARCHAR(20) COMMENT 'The title the person prefers to be addressed by, ie Mr, Ms, Dr. etc';

ALTER TABLE EmailCustomers MODIFY COLUMN GivenName VARCHAR(100) COMMENT 'A given name may also include a middle name or initial';

ALTER TABLE EmailCustomers MODIFY COLUMN Surname VARCHAR(100) COMMENT 'Family name; Last in most western countries, first in most eastern countries';


CREATE TABLE EmailCustomers_LegacyEmailOrders (
                EmailCustomerId INT NOT NULL,
                EmailOrderId INT NOT NULL,
                NameNeedsReview BOOLEAN DEFAULT 0 NOT NULL,
                EmailNeedsReview BOOLEAN DEFAULT 0 NOT NULL,
                ConversionNotes VARCHAR(250),
                PRIMARY KEY (EmailCustomerId, EmailOrderId)
);

ALTER TABLE EmailCustomers_LegacyEmailOrders COMMENT 'Map customer back to legacy orders it was extracted from
along w/ notes about conversion';

ALTER TABLE EmailCustomers_LegacyEmailOrders MODIFY COLUMN NameNeedsReview BOOLEAN COMMENT 'Conversion of legacy fullname needs manual review';

ALTER TABLE EmailCustomers_LegacyEmailOrders MODIFY COLUMN ConversionNotes VARCHAR(250) COMMENT 'Notes about the conversion of the legacy order';


CREATE TABLE EmailCustomerCreditCards (
                EmailCustomerId INT NOT NULL,
                N TINYINT NOT NULL,
                CCIssuerId TINYINT NOT NULL,
                CardNumber VARCHAR(20) NOT NULL,
                ExpDate DATE NOT NULL,
                CVV SMALLINT NOT NULL,
                PRIMARY KEY (EmailCustomerId, N)
);

ALTER TABLE EmailCustomerCreditCards MODIFY COLUMN N TINYINT COMMENT 'pkN makes this a unique creditcard record pk for the email customer';

ALTER TABLE EmailCustomerCreditCards MODIFY COLUMN ExpDate DATE COMMENT 'Expiration Month and Year (DoM is not used)';

ALTER TABLE EmailCustomerCreditCards MODIFY COLUMN CVV SMALLINT COMMENT 'Card Verification Value 3-4 digits (TODO, probably should not be stored)';


CREATE TABLE EmailCustomerPhoneNumbers (
                EmailCustomerId INT NOT NULL,
                N TINYINT NOT NULL,
                PhoneNumber VARCHAR(25) NOT NULL,
                Type VARCHAR(15) NOT NULL,
                PRIMARY KEY (EmailCustomerId, N)
);

ALTER TABLE EmailCustomerPhoneNumbers MODIFY COLUMN N TINYINT COMMENT 'N makes this a unique phone number record pk for the email customer';

ALTER TABLE EmailCustomerPhoneNumbers MODIFY COLUMN PhoneNumber VARCHAR(25) COMMENT 'Free form phone number';

ALTER TABLE EmailCustomerPhoneNumbers MODIFY COLUMN Type VARCHAR(15) COMMENT 'free form type of number, e.g. home, work, mobile, cell, fax, home2, etc.';


CREATE TABLE EmailCustomers_ShippingAddresses (
                EmailCustomerId INT NOT NULL,
                AddressId INT NOT NULL,
                PRIMARY KEY (EmailCustomerId, AddressId)
);


CREATE TABLE Orders (
                OrderId INT AUTO_INCREMENT NOT NULL,
                OrderDate DATE NOT NULL,
                AccountingOrderNo VARCHAR(15) NOT NULL,
                EmailCustomerId INT NOT NULL,
                AddressId INT NOT NULL,
                RetailerId INT NOT NULL,
                AdditionalCharges VARCHAR(120),
                Notes VARCHAR(250),
                PRIMARY KEY (OrderId)
);

ALTER TABLE Orders MODIFY COLUMN OrderDate DATE COMMENT 'Date the order was placed';

ALTER TABLE Orders MODIFY COLUMN AccountingOrderNo VARCHAR(15) COMMENT 'Accounting Order number for retailer that includes this order';

ALTER TABLE Orders MODIFY COLUMN AddressId INTEGER COMMENT 'Customer''s selected shipping address for this order';

ALTER TABLE Orders MODIFY COLUMN Notes VARCHAR(250) COMMENT 'Notes about the order to include on the invoice';


CREATE TABLE OrderInvoices (
                OrderId INT NOT NULL,
                InvoicePDF LONGBLOB NOT NULL,
                PRIMARY KEY (OrderId)
);

ALTER TABLE OrderInvoices MODIFY COLUMN InvoicePDF BLOB COMMENT 'The Invoice PDF sent to the customer';


CREATE TABLE Orders_Wines (
                OrderId INT NOT NULL,
                WineId INT NOT NULL,
                QtyCases TINYINT DEFAULT 0 NOT NULL,
                QtyUnits TINYINT DEFAULT 0 NOT NULL,
                CasePrice DECIMAL(8,2) NOT NULL,
                UnitPrice DECIMAL(8,2) NOT NULL,
                PRIMARY KEY (OrderId, WineId)
);

ALTER TABLE Orders_Wines MODIFY COLUMN QtyCases TINYINT COMMENT 'Number of full cases ordered';

ALTER TABLE Orders_Wines MODIFY COLUMN QtyUnits TINYINT COMMENT 'Number of units (bottles, BiB, etc) in partial case ordered';

ALTER TABLE Orders_Wines MODIFY COLUMN CasePrice DECIMAL(8, 2) COMMENT 'Price for full cases ordered';

ALTER TABLE Orders_Wines MODIFY COLUMN UnitPrice DECIMAL(8, 2) COMMENT 'Price for units (bottles, BiB, etc) in partial case ordered';


ALTER TABLE Wines ADD CONSTRAINT lookupwineappellations_wines_fk
FOREIGN KEY (WineAppellationId)
REFERENCES LookupWineAppellations (WineAppellationId)
ON DELETE SET NULL
ON UPDATE NO ACTION;

ALTER TABLE Wines ADD CONSTRAINT lookupwinesubregions_wines_fk
FOREIGN KEY (WineSubregionId)
REFERENCES LookupWineSubregions (WineSubregionId)
ON DELETE SET NULL
ON UPDATE NO ACTION;

ALTER TABLE Wines ADD CONSTRAINT lookupwineregions_wines_fk
FOREIGN KEY (WineRegionId)
REFERENCES LookupWineRegions (WineRegionId)
ON DELETE SET NULL
ON UPDATE NO ACTION;

ALTER TABLE Wines ADD CONSTRAINT lookupwinecountries_wines_fk
FOREIGN KEY (WineCountryId)
REFERENCES LookupWineCountries (WineCountryId)
ON DELETE NO ACTION
ON UPDATE NO ACTION;

ALTER TABLE Wines ADD CONSTRAINT lookupwinecolors_wines_fk
FOREIGN KEY (WineColorId)
REFERENCES LookupWineColors (WineColorId)
ON DELETE NO ACTION
ON UPDATE NO ACTION;

ALTER TABLE Producers_LegacyWineMaster ADD CONSTRAINT legacywinemaster_1106_producers_legacywinemaster_fk
FOREIGN KEY (WineId)
REFERENCES LegacyWineMaster_1218 (WineId)
ON DELETE NO ACTION
ON UPDATE NO ACTION;

ALTER TABLE Orders ADD CONSTRAINT retailers_orders_fk
FOREIGN KEY (RetailerId)
REFERENCES Retailers (RetailerId)
ON DELETE NO ACTION
ON UPDATE NO ACTION;

ALTER TABLE EmailCustomers_LegacyEmailOrders ADD CONSTRAINT legacyemailorders_1106_emailcustomer_legacyemailorders_fk
FOREIGN KEY (EmailOrderId)
REFERENCES LegacyEmailOrders_1106 (EmailOrderId)
ON DELETE NO ACTION
ON UPDATE NO ACTION;

ALTER TABLE Wines ADD CONSTRAINT lookupwinetypes_wines_fk
FOREIGN KEY (WineTypeId)
REFERENCES LookupWineTypes (WineTypeId)
ON DELETE NO ACTION
ON UPDATE NO ACTION;

ALTER TABLE EmailCustomerCreditCards ADD CONSTRAINT lookupccissuers_emailcustomercreditcards_fk
FOREIGN KEY (CCIssuerId)
REFERENCES LookupCCIssuers (CCIssuerId)
ON DELETE NO ACTION
ON UPDATE NO ACTION;

ALTER TABLE Wines ADD CONSTRAINT lookupunits_wines_fk
FOREIGN KEY (CaseUnitId)
REFERENCES LookupCaseUnits (CaseUnitId)
ON DELETE NO ACTION
ON UPDATE NO ACTION;

ALTER TABLE Wines ADD CONSTRAINT producers_wines_fk
FOREIGN KEY (ProducerId)
REFERENCES Producers (ProducerId)
ON DELETE NO ACTION
ON UPDATE NO ACTION;

ALTER TABLE Producers_LegacyWineMaster ADD CONSTRAINT producers_producers_legacywinemaster_fk
FOREIGN KEY (ProducerId)
REFERENCES Producers (ProducerId)
ON DELETE NO ACTION
ON UPDATE NO ACTION;

ALTER TABLE EmailCustomers_ShippingAddresses ADD CONSTRAINT addresses_emailcustomers_address_fk
FOREIGN KEY (AddressId)
REFERENCES Addresses (AddressId)
ON DELETE NO ACTION
ON UPDATE NO ACTION;

ALTER TABLE Orders_Wines ADD CONSTRAINT wines_orders_wines_fk
FOREIGN KEY (WineId)
REFERENCES Wines (WineId)
ON DELETE NO ACTION
ON UPDATE NO ACTION;

ALTER TABLE WinePricing ADD CONSTRAINT wines_winepricing_fk
FOREIGN KEY (WineId)
REFERENCES Wines (WineId)
ON DELETE NO ACTION
ON UPDATE NO ACTION;

ALTER TABLE NJ_Distribution ADD CONSTRAINT wines_nj_distribution_fk
FOREIGN KEY (WineId)
REFERENCES Wines (WineId)
ON DELETE NO ACTION
ON UPDATE NO ACTION;

ALTER TABLE EmailCustomers_ShippingAddresses ADD CONSTRAINT emailcustomers_emailcustomers_address_fk
FOREIGN KEY (EmailCustomerId)
REFERENCES EmailCustomers (EmailCustomerId)
ON DELETE NO ACTION
ON UPDATE NO ACTION;

ALTER TABLE EmailCustomerPhoneNumbers ADD CONSTRAINT emailcustomers_emailcustomerphonenumbers_fk
FOREIGN KEY (EmailCustomerId)
REFERENCES EmailCustomers (EmailCustomerId)
ON DELETE NO ACTION
ON UPDATE NO ACTION;

ALTER TABLE EmailCustomerCreditCards ADD CONSTRAINT emailcustomers_emailcustomercreditcards_fk
FOREIGN KEY (EmailCustomerId)
REFERENCES EmailCustomers (EmailCustomerId)
ON DELETE NO ACTION
ON UPDATE NO ACTION;

ALTER TABLE Orders ADD CONSTRAINT emailcustomers_orders_fk
FOREIGN KEY (EmailCustomerId)
REFERENCES EmailCustomers (EmailCustomerId)
ON DELETE NO ACTION
ON UPDATE NO ACTION;

ALTER TABLE EmailCustomers_LegacyEmailOrders ADD CONSTRAINT emailcustomers_emailcustomer_legacyemailorders_fk
FOREIGN KEY (EmailCustomerId)
REFERENCES EmailCustomers (EmailCustomerId)
ON DELETE NO ACTION
ON UPDATE NO ACTION;

ALTER TABLE Orders ADD CONSTRAINT emailcustomers_shippingaddresses_orders_fk
FOREIGN KEY (EmailCustomerId, AddressId)
REFERENCES EmailCustomers_ShippingAddresses (EmailCustomerId, AddressId)
ON DELETE NO ACTION
ON UPDATE NO ACTION;

ALTER TABLE Orders_Wines ADD CONSTRAINT orders_orders_wines_fk
FOREIGN KEY (OrderId)
REFERENCES Orders (OrderId)
ON DELETE NO ACTION
ON UPDATE NO ACTION;

ALTER TABLE OrderInvoices ADD CONSTRAINT orders_orderinvoices_fk
FOREIGN KEY (OrderId)
REFERENCES Orders (OrderId)
ON DELETE NO ACTION
ON UPDATE NO ACTION;
