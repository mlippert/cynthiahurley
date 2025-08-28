
CREATE TABLE LookupCaseUnits (
                pkCaseUnit TINYINT NOT NULL,
                Name VARCHAR NOT NULL,
                CONSTRAINT pkCaseUnit PRIMARY KEY (pkCaseUnit)
);

CREATE TABLE Producers (
                pkProducer INTEGER NOT NULL,
                Name VARCHAR NOT NULL,
                Region VARCHAR NOT NULL,
                CONSTRAINT pkProducer PRIMARY KEY (pkProducer)
);

-- Comment for table [Producers]: A wine producer;


CREATE TABLE Distributors (
                pkDistributor INTEGER NOT NULL,
                Name VARCHAR NOT NULL,
                Email VARCHAR NOT NULL,
                CONSTRAINT pkDistributor PRIMARY KEY (pkDistributor)
);

-- Comment for table [Distributors]: The distributor is responsible for getting the order to the email customer;


CREATE TABLE Addresses (
                pkAddress INTEGER NOT NULL,
                Street VARCHAR NOT NULL,
                Street2 VARCHAR,
                City VARCHAR NOT NULL,
                State VARCHAR NOT NULL,
                PostalCode VARCHAR NOT NULL,
                CONSTRAINT pkAddress PRIMARY KEY (pkAddress)
);

CREATE TABLE Wines (
                pkWine INTEGER NOT NULL,
                ItemNo VARCHAR NOT NULL,
                Name VARCHAR NOT NULL,
                Vintage SMALLINT NOT NULL,
                fkProducer INTEGER NOT NULL,
                Available BIT DEFAULT 1 NOT NULL,
                SoldOut BIT DEFAULT 0 NOT NULL,
                UnitsPerCase SMALLINT NOT NULL,
                fkCaseUnit TINYINT NOT NULL,
                CONSTRAINT pkWine PRIMARY KEY (pkWine)
);

CREATE TABLE EmailCustomers (
                pkEmailCustomer INTEGER NOT NULL,
                Created TIMESTAMP NOT NULL,
                CreatedBy VARCHAR NOT NULL,
                LastModified TIMESTAMP NOT NULL,
                LastModifiedBy VARCHAR NOT NULL,
                FirstName VARCHAR NOT NULL,
                LastName VARCHAR NOT NULL,
                Email VARCHAR NOT NULL,
                CONSTRAINT pkEmailCustomer PRIMARY KEY (pkEmailCustomer)
);

CREATE TABLE EmailCustomerCreditCards (
                fkEmailCustomer INTEGER NOT NULL,
                pkN TINYINT NOT NULL,
                CardNumber VARCHAR NOT NULL,
                Issuer VARCHAR NOT NULL,
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
