
CREATE TABLE LegacyWineMaster (
                WineId INT AUTO_INCREMENT NOT NULL,
                AccountingItemNo VARCHAR(11),
                NYPPItemNo VARCHAR(17),
                WesternItemNo VARCHAR(11),
                COLA_TTBID VARCHAR(15),
                UPC VARCHAR(13),
                FullName VARCHAR(100) NOT NULL,
                Vintage SMALLINT,
                Color VARCHAR(5),
                StillSparklingFortified VARCHAR(9),
                CertifiedOrganic VARCHAR(19),
                Varietals VARCHAR(100),
                ABV DECIMAL(5,2),
                Country VARCHAR(6),
                Region VARCHAR(16),
                SubRegion VARCHAR(16),
                Appellation VARCHAR(46),
                YearEstablished VARCHAR(27),
                ProducerName VARCHAR(46),
                ProoducerDescription TEXT(1015),
                FrontLabelFilename VARCHAR(86),
                ShelfTalkerText TEXT(824),
                TastingNotes TEXT(998),
                Vinification TEXT(917),
                TerroirVineyardPractices TEXT(1087),
                PressParagraph TEXT(3728) AUTO_INCREMENT,
                BottleSize VARCHAR(18),
                BottlesPerCase TINYINT,
                BottleColor VARCHAR(6),
                Excluded VARCHAR(24),
                SoldOut VARCHAR(1),
                COLA_PDF_Filename VARCHAR(70),
                FOBPrice DECIMAL(8,2),
                CurrentNewYorkPricing VARCHAR(42),
                CurrentNewJerseyPricing VARCHAR(30),
                CurrentMassachusettsPricing VARCHAR(29),
                MABottlePrice DOUBLE PRECISION NOT NULL,
                PriceListSection VARCHAR(31),
                PriceListNotes VARCHAR(115),
                DateCreated DATE,
                LastUpdated DATETIME,
                PRIMARY KEY (WineId)
);

ALTER TABLE LegacyWineMaster MODIFY COLUMN Vintage SMALLINT COMMENT '4 digit year';

ALTER TABLE LegacyWineMaster MODIFY COLUMN Varietals VARCHAR(100) COMMENT 'Comma separated list of the grape varietals in the wine';

ALTER TABLE LegacyWineMaster MODIFY COLUMN ABV DECIMAL(5, 2) COMMENT 'Alcohol % by volume';

ALTER TABLE LegacyWineMaster MODIFY COLUMN SoldOut VARCHAR(1) COMMENT 'True(1)-sold out, False(0)-in stock';

ALTER TABLE LegacyWineMaster MODIFY COLUMN MABottlePrice DOUBLE COMMENT 'Currently contains a worthless value, s/b DECIMAL(8,2)';


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
                VolumeInMilliliters INT NOT NULL,
                UnitType VARCHAR(15) NOT NULL,
                PRIMARY KEY (CaseUnitId)
);

ALTER TABLE LookupCaseUnits MODIFY COLUMN Name VARCHAR(30) COMMENT 'Composite description of the Unit, e.g. Bottle 750ml, Can 20oz, BiB 500ml';

ALTER TABLE LookupCaseUnits MODIFY COLUMN VolumeInMilliliters INTEGER COMMENT 'Volume in this unit in milliliters';

ALTER TABLE LookupCaseUnits MODIFY COLUMN UnitType VARCHAR(15) COMMENT 'Type of unit: bottle, can, BiB (bag in box)';


CREATE TABLE Producers (
                ProducerId INT NOT NULL,
                Name VARCHAR(200) NOT NULL,
                Description TEXT(20000) NOT NULL,
                YearEstablished SMALLINT NOT NULL,
                PRIMARY KEY (ProducerId)
);

ALTER TABLE Producers COMMENT 'A wine producer';


CREATE TABLE Distributors (
                DistributorId INT AUTO_INCREMENT NOT NULL,
                Name VARCHAR(200) NOT NULL,
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
                AccountingItemNo VARCHAR(10) NOT NULL,
                COLA_TTBID VARCHAR(15) NOT NULL,
                UPC VARCHAR(15) NOT NULL,
                Name VARCHAR(100) NOT NULL,
                Vintage SMALLINT NOT NULL,
                Color VARCHAR(15) NOT NULL,
                StillSparklingFortified VARCHAR(15) NOT NULL,
                CertifiedOrganic BOOLEAN NOT NULL,
                Varietals VARCHAR(100) NOT NULL,
                ABV DECIMAL(5,2) NOT NULL,
                Country VARCHAR(100) NOT NULL,
                Region VARCHAR(100) NOT NULL,
                SubRegion VARCHAR(100) NOT NULL,
                Appellation VARCHAR(100) NOT NULL,
                ProducerId INT NOT NULL,
                Available BOOLEAN NOT NULL,
                SoldOut BOOLEAN NOT NULL,
                UnitsPerCase SMALLINT NOT NULL,
                CaseUnitId TINYINT NOT NULL,
                BottleColor VARCHAR(15) NOT NULL,
                ShelfTalkerText TEXT(20000) NOT NULL,
                TastingNotes TEXT(20000) NOT NULL,
                Vinification TEXT(20000) NOT NULL,
                TerroirVineyardPractices TEXT(20000) NOT NULL,
                PressParagraph TEXT(20000) NOT NULL,
                CreationTimestamp DATETIME NOT NULL,
                CreatedBy VARCHAR(32) NOT NULL,
                ModificationTimestamp DATETIME NOT NULL,
                ModifiedBy VARCHAR(32) NOT NULL,
                PRIMARY KEY (WineId)
);

ALTER TABLE Wines MODIFY COLUMN Vintage SMALLINT COMMENT '4 digit year';

ALTER TABLE Wines MODIFY COLUMN Varietals VARCHAR(100) COMMENT 'Comma separated list of the grape varietals in the wine';

ALTER TABLE Wines MODIFY COLUMN ABV DECIMAL(5, 2) COMMENT 'Alcohol % by volume';

ALTER TABLE Wines MODIFY COLUMN Available BOOLEAN COMMENT 'If a wine is not available it should be excluded from the list of wines for sale (True(1)-available, False(0)-excluded)';

ALTER TABLE Wines MODIFY COLUMN SoldOut BOOLEAN COMMENT 'True(1)-sold out, False(0)-in stock';

ALTER TABLE Wines MODIFY COLUMN UnitsPerCase SMALLINT COMMENT 'Units of wine include various size bottles, boxes and cans
Retail sales are sometimes by case and sometimes by unit';

ALTER TABLE Wines MODIFY COLUMN CaseUnitId TINYINT COMMENT 'Type of unit in a case of this wine';

ALTER TABLE Wines MODIFY COLUMN CreatedBy VARCHAR(32) COMMENT 'User who created this record';

ALTER TABLE Wines MODIFY COLUMN ModifiedBy VARCHAR(32) COMMENT 'User who last modified this record';


CREATE TABLE WinePricing (
                WineId INT NOT NULL,
                NYPPItemNo VARCHAR(20) NOT NULL,
                WesternItemNo VARCHAR(20) NOT NULL,
                WesternInventoryBottlesAvailable INT NOT NULL,
                PriceListSection VARCHAR(50) NOT NULL,
                PriceListNotes VARCHAR(50) NOT NULL,
                FOBPrice DECIMAL(8,2) NOT NULL,
                CurrentMassachusettsPricing VARCHAR(100) NOT NULL,
                CurrentNewJerseyPricing VARCHAR(100) NOT NULL,
                CurrentNewYorkPricing VARCHAR(100) NOT NULL,
                MABottlePrice DECIMAL(8,2) NOT NULL,
                WinebowPrice DECIMAL(8,2) NOT NULL,
                WinebowSpecialPrice BOOLEAN NOT NULL,
                PRIMARY KEY (WineId)
);

ALTER TABLE WinePricing COMMENT 'Interim table to gather existing wine pricing fields';


CREATE TABLE EmailCustomers (
                EmailCustomerId INT AUTO_INCREMENT NOT NULL,
                Created DATETIME NOT NULL,
                CreatedBy VARCHAR(30) NOT NULL,
                LastModified DATETIME NOT NULL,
                LastModifiedBy VARCHAR(30) NOT NULL,
                FirstName VARCHAR(100) NOT NULL,
                LastName VARCHAR(100) NOT NULL,
                Email VARCHAR(200) NOT NULL,
                PRIMARY KEY (EmailCustomerId)
);


CREATE TABLE EmailCustomerCreditCards (
                EmailCustomerId INT NOT NULL,
                N TINYINT NOT NULL,
                CCIssuerId TINYINT NOT NULL,
                CardNumber VARCHAR(20) NOT NULL,
                ExpDate DATE NOT NULL,
                SecurityCode SMALLINT NOT NULL,
                PRIMARY KEY (EmailCustomerId, N)
);

ALTER TABLE EmailCustomerCreditCards MODIFY COLUMN N TINYINT COMMENT 'pkN makes this a unique creditcard record pk for the email customer';

ALTER TABLE EmailCustomerCreditCards MODIFY COLUMN ExpDate DATE COMMENT 'Expiration Month and Year (DoM is not used)';

ALTER TABLE EmailCustomerCreditCards MODIFY COLUMN SecurityCode SMALLINT COMMENT 'Security code 3 digits (TODO, probably should not be stored)';


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
                OrderNo INT NOT NULL,
                EmailCustomerId INT NOT NULL,
                AddressId INT NOT NULL,
                DistributorId INT NOT NULL,
                PRIMARY KEY (OrderId)
);

ALTER TABLE Orders MODIFY COLUMN OrderNo INTEGER COMMENT '7 digit order reference number';

ALTER TABLE Orders MODIFY COLUMN AddressId INTEGER COMMENT 'Customer''s selected shipping address for this order';

ALTER TABLE Orders MODIFY COLUMN DistributorId INTEGER COMMENT 'Distributor who will fulfill this order (serving shipping address)';


CREATE TABLE Orders_Wines (
                OrderId INT NOT NULL,
                WineId INT NOT NULL,
                PRIMARY KEY (OrderId, WineId)
);


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

ALTER TABLE Orders ADD CONSTRAINT distributors_orders_fk
FOREIGN KEY (DistributorId)
REFERENCES Distributors (DistributorId)
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
