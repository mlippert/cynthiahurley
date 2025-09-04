
CREATE TABLE LookupCCIssuers (
                CCIssuerId IDENTITY NOT NULL,
                Name VARCHAR(20) NOT NULL,
                CONSTRAINT pkCCIssuer PRIMARY KEY (CCIssuerId)
);

CREATE TABLE LookupCaseUnits (
                CaseUnitId IDENTITY NOT NULL,
                Name VARCHAR(30) NOT NULL,
                CONSTRAINT pkCaseUnit PRIMARY KEY (CaseUnitId)
);

CREATE TABLE Producers (
                ProducerId INTEGER NOT NULL,
                Name VARCHAR(200) NOT NULL,
                Region VARCHAR(100) NOT NULL,
                CONSTRAINT pkProducer PRIMARY KEY (ProducerId)
);

-- Comment for table [Producers]: A wine producer;


CREATE TABLE Distributors (
                DistributorId IDENTITY NOT NULL,
                Name VARCHAR(200) NOT NULL,
                Email VARCHAR(200) NOT NULL,
                CONSTRAINT pkDistributor PRIMARY KEY (DistributorId)
);

-- Comment for table [Distributors]: The distributor is responsible for getting the order to the email customer;


CREATE TABLE Addresses (
                AddressId IDENTITY NOT NULL,
                Street VARCHAR(150) NOT NULL,
                Street2 VARCHAR(150),
                City VARCHAR(100) NOT NULL,
                State VARCHAR(100) NOT NULL,
                PostalCode VARCHAR(30) NOT NULL,
                CONSTRAINT pkAddress PRIMARY KEY (AddressId)
);

CREATE TABLE Wines (
                WineId IDENTITY NOT NULL,
                ItemNo VARCHAR(10) NOT NULL,
                Name VARCHAR(100) NOT NULL,
                Vintage SMALLINT NOT NULL,
                ProducerId INTEGER NOT NULL,
                Available BOOLEAN NOT NULL,
                SoldOut BOOLEAN NOT NULL,
                UnitsPerCase SMALLINT NOT NULL,
                CaseUnitId TINYINT NOT NULL,
                CONSTRAINT pkWine PRIMARY KEY (WineId)
);

CREATE TABLE EmailCustomers (
                EmailCustomerId IDENTITY NOT NULL,
                Created TIMESTAMP NOT NULL,
                CreatedBy VARCHAR(30) NOT NULL,
                LastModified TIMESTAMP NOT NULL,
                LastModifiedBy VARCHAR(30) NOT NULL,
                FirstName VARCHAR(100) NOT NULL,
                LastName VARCHAR(100) NOT NULL,
                Email VARCHAR(200) NOT NULL,
                CONSTRAINT pkEmailCustomer PRIMARY KEY (EmailCustomerId)
);

CREATE TABLE EmailCustomerCreditCards (
                EmailCustomerId INTEGER NOT NULL,
                N TINYINT NOT NULL,
                CCIssuerId TINYINT NOT NULL,
                CardNumber VARCHAR(20) NOT NULL,
                ExpDate DATE NOT NULL,
                SecurityCode SMALLINT NOT NULL,
                CONSTRAINT pkEmailCustomerCreditCard PRIMARY KEY (EmailCustomerId, N)
);

CREATE TABLE EmailCustomerPhoneNumbers (
                EmailCustomerId INTEGER NOT NULL,
                N TINYINT NOT NULL,
                PhoneNumber VARCHAR(25) NOT NULL,
                Type VARCHAR(15) NOT NULL,
                CONSTRAINT pkEmailCustomerPhoneNumber PRIMARY KEY (EmailCustomerId, N)
);

CREATE TABLE EmailCustomers_ShippingAddresses (
                EmailCustomerId INTEGER NOT NULL,
                AddressId INTEGER NOT NULL,
                CONSTRAINT pkEmailCustomers_ShippingAddress PRIMARY KEY (EmailCustomerId, AddressId)
);

CREATE TABLE Orders (
                OrderId IDENTITY NOT NULL,
                OrderNo INTEGER NOT NULL,
                EmailCustomerId INTEGER NOT NULL,
                AddressId INTEGER NOT NULL,
                DistributorId INTEGER NOT NULL,
                CONSTRAINT pkOrder PRIMARY KEY (OrderId)
);

CREATE TABLE Orders_Wines (
                OrderId INTEGER NOT NULL,
                WineId INTEGER NOT NULL,
                CONSTRAINT pkOrders_Wines PRIMARY KEY (OrderId, WineId)
);

ALTER TABLE EmailCustomerCreditCards ADD CONSTRAINT LookupCCIssuers_EmailCustomerCreditCards_fk
FOREIGN KEY (CCIssuerId)
REFERENCES LookupCCIssuers (CCIssuerId)
ON DELETE NO ACTION
ON UPDATE NO ACTION;

ALTER TABLE Wines ADD CONSTRAINT LookupUnits_Wines_fk
FOREIGN KEY (CaseUnitId)
REFERENCES LookupCaseUnits (CaseUnitId)
ON DELETE NO ACTION
ON UPDATE NO ACTION;

ALTER TABLE Wines ADD CONSTRAINT Producers_Wines_fk
FOREIGN KEY (ProducerId)
REFERENCES Producers (ProducerId)
ON DELETE NO ACTION
ON UPDATE NO ACTION;

ALTER TABLE Orders ADD CONSTRAINT Distributors_Orders_fk
FOREIGN KEY (DistributorId)
REFERENCES Distributors (DistributorId)
ON DELETE NO ACTION
ON UPDATE NO ACTION;

ALTER TABLE EmailCustomers_ShippingAddresses ADD CONSTRAINT Addresses_EmailCustomers_Address_fk
FOREIGN KEY (AddressId)
REFERENCES Addresses (AddressId)
ON DELETE NO ACTION
ON UPDATE NO ACTION;

ALTER TABLE Orders_Wines ADD CONSTRAINT Wines_Orders_Wines_fk
FOREIGN KEY (WineId)
REFERENCES Wines (WineId)
ON DELETE NO ACTION
ON UPDATE NO ACTION;

ALTER TABLE EmailCustomers_ShippingAddresses ADD CONSTRAINT EmailCustomers_EmailCustomers_Address_fk
FOREIGN KEY (EmailCustomerId)
REFERENCES EmailCustomers (EmailCustomerId)
ON DELETE NO ACTION
ON UPDATE NO ACTION;

ALTER TABLE EmailCustomerPhoneNumbers ADD CONSTRAINT EmailCustomers_EmailCustomerPhoneNumbers_fk
FOREIGN KEY (EmailCustomerId)
REFERENCES EmailCustomers (EmailCustomerId)
ON DELETE NO ACTION
ON UPDATE NO ACTION;

ALTER TABLE EmailCustomerCreditCards ADD CONSTRAINT EmailCustomers_EmailCustomerCreditCards_fk
FOREIGN KEY (EmailCustomerId)
REFERENCES EmailCustomers (EmailCustomerId)
ON DELETE NO ACTION
ON UPDATE NO ACTION;

ALTER TABLE Orders ADD CONSTRAINT EmailCustomers_Orders_fk
FOREIGN KEY (EmailCustomerId)
REFERENCES EmailCustomers (EmailCustomerId)
ON DELETE NO ACTION
ON UPDATE NO ACTION;

ALTER TABLE Orders ADD CONSTRAINT EmailCustomers_ShippingAddresses_Orders_fk
FOREIGN KEY (EmailCustomerId, AddressId)
REFERENCES EmailCustomers_ShippingAddresses (EmailCustomerId, AddressId)
ON DELETE NO ACTION
ON UPDATE NO ACTION;

ALTER TABLE Orders_Wines ADD CONSTRAINT Orders_Orders_Wines_fk
FOREIGN KEY (OrderId)
REFERENCES Orders (OrderId)
ON DELETE NO ACTION
ON UPDATE NO ACTION;
