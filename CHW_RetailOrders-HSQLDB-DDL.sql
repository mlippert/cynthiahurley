
CREATE TABLE LookupCCIssuers (
                pkCCIssuer IDENTITY NOT NULL,
                Name VARCHAR(20) NOT NULL,
                CONSTRAINT pkCCIssuer PRIMARY KEY (pkCCIssuer)
);

CREATE TABLE LookupCaseUnits (
                pkCaseUnit TINYINT NOT NULL,
                Name VARCHAR(30) NOT NULL,
                CONSTRAINT pkCaseUnit PRIMARY KEY (pkCaseUnit)
);

CREATE TABLE Producers (
                pkProducer INTEGER NOT NULL,
                Name VARCHAR(200) NOT NULL,
                Region VARCHAR(100) NOT NULL,
                CONSTRAINT pkProducer PRIMARY KEY (pkProducer)
);

-- Comment for table [Producers]: A wine producer;


CREATE TABLE Distributors (
                pkDistributor INTEGER NOT NULL,
                Name VARCHAR(200) NOT NULL,
                Email VARCHAR(200) NOT NULL,
                CONSTRAINT pkDistributor PRIMARY KEY (pkDistributor)
);

-- Comment for table [Distributors]: The distributor is responsible for getting the order to the email customer;


CREATE TABLE Addresses (
                pkAddress INTEGER NOT NULL,
                Street VARCHAR(150) NOT NULL,
                Street2 VARCHAR(150),
                City VARCHAR(100) NOT NULL,
                State VARCHAR(100) NOT NULL,
                PostalCode VARCHAR(30) NOT NULL,
                CONSTRAINT pkAddress PRIMARY KEY (pkAddress)
);

CREATE TABLE Wines (
                pkWine INTEGER NOT NULL,
                ItemNo VARCHAR(10) NOT NULL,
                Name VARCHAR(100) NOT NULL,
                Vintage SMALLINT NOT NULL,
                fkProducer INTEGER NOT NULL,
                Available BOOLEAN NOT NULL,
                SoldOut BOOLEAN NOT NULL,
                UnitsPerCase SMALLINT NOT NULL,
                fkCaseUnit TINYINT NOT NULL,
                CONSTRAINT pkWine PRIMARY KEY (pkWine)
);

CREATE TABLE EmailCustomers (
                pkEmailCustomer INTEGER NOT NULL,
                Created TIMESTAMP NOT NULL,
                CreatedBy VARCHAR(30) NOT NULL,
                LastModified TIMESTAMP NOT NULL,
                LastModifiedBy VARCHAR(30) NOT NULL,
                FirstName VARCHAR(100) NOT NULL,
                LastName VARCHAR(100) NOT NULL,
                Email VARCHAR(200) NOT NULL,
                CONSTRAINT pkEmailCustomer PRIMARY KEY (pkEmailCustomer)
);

CREATE TABLE EmailCustomerCreditCards (
                fkEmailCustomer INTEGER NOT NULL,
                pkN TINYINT NOT NULL,
                fkCCIssuer TINYINT NOT NULL,
                CardNumber VARCHAR(20) NOT NULL,
                ExpDate DATE NOT NULL,
                SecurityCode SMALLINT NOT NULL,
                CONSTRAINT pkEmailCustomerCreditCard PRIMARY KEY (fkEmailCustomer, pkN)
);

CREATE TABLE EmailCustomerPhoneNumbers (
                fkEmailCustomer INTEGER NOT NULL,
                pkN TINYINT NOT NULL,
                CONSTRAINT pkEmailCustomerPhoneNumber PRIMARY KEY (fkEmailCustomer, pkN)
);

CREATE TABLE EmailCustomers_ShippingAddresses (
                fkEmailCustomer INTEGER NOT NULL,
                fkAddress INTEGER NOT NULL,
                CONSTRAINT pkEmailCustomers_ShippingAddress PRIMARY KEY (fkEmailCustomer, fkAddress)
);

CREATE TABLE Orders (
                pkOrder INTEGER NOT NULL,
                OrderNo INTEGER NOT NULL,
                fkEmailCustomer INTEGER NOT NULL,
                fkAddress INTEGER NOT NULL,
                fkDistributor INTEGER NOT NULL,
                CONSTRAINT pkOrder PRIMARY KEY (pkOrder)
);

CREATE TABLE Orders_Wines (
                fkOrder INTEGER NOT NULL,
                fkWine INTEGER NOT NULL,
                CONSTRAINT pkOrders_Wines PRIMARY KEY (fkOrder, fkWine)
);

ALTER TABLE EmailCustomerCreditCards ADD CONSTRAINT LookupCCIssuers_EmailCustomerCreditCards_fk
FOREIGN KEY (fkCCIssuer)
REFERENCES LookupCCIssuers (pkCCIssuer)
ON DELETE NO ACTION
ON UPDATE NO ACTION;

ALTER TABLE Wines ADD CONSTRAINT LookupUnits_Wines_fk
FOREIGN KEY (fkCaseUnit)
REFERENCES LookupCaseUnits (pkCaseUnit)
ON DELETE NO ACTION
ON UPDATE NO ACTION;

ALTER TABLE Wines ADD CONSTRAINT Producers_Wines_fk
FOREIGN KEY (fkProducer)
REFERENCES Producers (pkProducer)
ON DELETE NO ACTION
ON UPDATE NO ACTION;

ALTER TABLE Orders ADD CONSTRAINT Distributors_Orders_fk
FOREIGN KEY (fkDistributor)
REFERENCES Distributors (pkDistributor)
ON DELETE NO ACTION
ON UPDATE NO ACTION;

ALTER TABLE EmailCustomers_ShippingAddresses ADD CONSTRAINT Addresses_EmailCustomers_Address_fk
FOREIGN KEY (fkAddress)
REFERENCES Addresses (pkAddress)
ON DELETE NO ACTION
ON UPDATE NO ACTION;

ALTER TABLE Orders_Wines ADD CONSTRAINT Wines_Orders_Wines_fk
FOREIGN KEY (fkWine)
REFERENCES Wines (pkWine)
ON DELETE NO ACTION
ON UPDATE NO ACTION;

ALTER TABLE EmailCustomers_ShippingAddresses ADD CONSTRAINT EmailCustomers_EmailCustomers_Address_fk
FOREIGN KEY (fkEmailCustomer)
REFERENCES EmailCustomers (pkEmailCustomer)
ON DELETE NO ACTION
ON UPDATE NO ACTION;

ALTER TABLE EmailCustomerPhoneNumbers ADD CONSTRAINT EmailCustomers_EmailCustomerPhoneNumbers_fk
FOREIGN KEY (fkEmailCustomer)
REFERENCES EmailCustomers (pkEmailCustomer)
ON DELETE NO ACTION
ON UPDATE NO ACTION;

ALTER TABLE EmailCustomerCreditCards ADD CONSTRAINT EmailCustomers_EmailCustomerCreditCards_fk
FOREIGN KEY (fkEmailCustomer)
REFERENCES EmailCustomers (pkEmailCustomer)
ON DELETE NO ACTION
ON UPDATE NO ACTION;

ALTER TABLE Orders ADD CONSTRAINT EmailCustomers_Orders_fk
FOREIGN KEY (fkEmailCustomer)
REFERENCES EmailCustomers (pkEmailCustomer)
ON DELETE NO ACTION
ON UPDATE NO ACTION;

ALTER TABLE Orders ADD CONSTRAINT EmailCustomers_ShippingAddresses_Orders_fk
FOREIGN KEY (fkEmailCustomer, fkAddress)
REFERENCES EmailCustomers_ShippingAddresses (fkEmailCustomer, fkAddress)
ON DELETE NO ACTION
ON UPDATE NO ACTION;

ALTER TABLE Orders_Wines ADD CONSTRAINT Orders_Orders_Wines_fk
FOREIGN KEY (fkOrder)
REFERENCES Orders (pkOrder)
ON DELETE NO ACTION
ON UPDATE NO ACTION;
