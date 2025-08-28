
CREATE TABLE LookupCaseUnits (
                pkCaseUnit TINYINT NOT NULL,
                Name VARCHAR NOT NULL,
                PRIMARY KEY (pkCaseUnit)
);

ALTER TABLE LookupCaseUnits MODIFY COLUMN Name VARCHAR COMMENT 'Description of the Unit, e.g. Bottle 750ml, Can 20oz, Box 500ml';


CREATE TABLE Producers (
                pkProducer INT NOT NULL,
                Name VARCHAR NOT NULL,
                Region VARCHAR NOT NULL,
                PRIMARY KEY (pkProducer)
);

ALTER TABLE Producers COMMENT 'A wine producer';


CREATE TABLE Distributors (
                pkDistributor INT NOT NULL,
                Name VARCHAR NOT NULL,
                Email VARCHAR NOT NULL,
                PRIMARY KEY (pkDistributor)
);

ALTER TABLE Distributors COMMENT 'The distributor is responsible for getting the order to the email customer';


CREATE TABLE Addresses (
                pkAddress INT NOT NULL,
                Street VARCHAR NOT NULL,
                Street2 VARCHAR,
                City VARCHAR NOT NULL,
                State VARCHAR NOT NULL,
                PostalCode VARCHAR NOT NULL,
                PRIMARY KEY (pkAddress)
);

ALTER TABLE Addresses MODIFY COLUMN Street2 VARCHAR COMMENT 'optional 2nd Street line for address';

ALTER TABLE Addresses MODIFY COLUMN PostalCode VARCHAR COMMENT 'zipcode in USA';


CREATE TABLE Wines (
                pkWine INT NOT NULL,
                ItemNo VARCHAR NOT NULL,
                Name VARCHAR NOT NULL,
                Vintage SMALLINT NOT NULL,
                fkProducer INT NOT NULL,
                Available TINYINT DEFAULT 1 NOT NULL,
                SoldOut TINYINT DEFAULT 0 NOT NULL,
                UnitsPerCase SMALLINT NOT NULL,
                fkCaseUnit TINYINT NOT NULL,
                PRIMARY KEY (pkWine)
);

ALTER TABLE Wines MODIFY COLUMN Vintage SMALLINT COMMENT '4 digit year';

ALTER TABLE Wines MODIFY COLUMN Available BIT COMMENT 'If a wine is not available it should be excluded from the list of wines for sale (1-available, 0-excluded)';

ALTER TABLE Wines MODIFY COLUMN SoldOut BIT COMMENT '1-sold out, 0-in stock';

ALTER TABLE Wines MODIFY COLUMN UnitsPerCase SMALLINT COMMENT 'Units of wine include various size bottles, boxes and cans
Retail sales are sometimes by case and sometimes by unit';

ALTER TABLE Wines MODIFY COLUMN fkCaseUnit TINYINT COMMENT 'Type of unit in a case of this wine';


CREATE TABLE EmailCustomers (
                pkEmailCustomer INT NOT NULL,
                Created DATETIME NOT NULL,
                CreatedBy VARCHAR NOT NULL,
                LastModified DATETIME NOT NULL,
                LastModifiedBy VARCHAR NOT NULL,
                FirstName VARCHAR NOT NULL,
                LastName VARCHAR NOT NULL,
                Email VARCHAR NOT NULL,
                PRIMARY KEY (pkEmailCustomer)
);


CREATE TABLE EmailCustomerCreditCards (
                fkEmailCustomer INT NOT NULL,
                pkN TINYINT NOT NULL,
                CardNumber VARCHAR NOT NULL,
                Issuer VARCHAR NOT NULL,
                PRIMARY KEY (fkEmailCustomer, pkN)
);

ALTER TABLE EmailCustomerCreditCards MODIFY COLUMN pkN TINYINT COMMENT 'pkN makes this a unique creditcard record pk for the email customer';

ALTER TABLE EmailCustomerCreditCards MODIFY COLUMN Issuer VARCHAR COMMENT 'Visa, MC, Discover, Amex, etc (see lookup table)';


CREATE TABLE EmailCustomerPhoneNumbers (
                fkEmailCustomer INT NOT NULL,
                pkN TINYINT NOT NULL,
                PRIMARY KEY (fkEmailCustomer, pkN)
);

ALTER TABLE EmailCustomerPhoneNumbers MODIFY COLUMN pkN TINYINT COMMENT 'pkN makes this a unique phone number record pk for the email customer';


CREATE TABLE EmailCustomers_ShippingAddresses (
                fkEmailCustomer INT NOT NULL,
                fkAddress INT NOT NULL,
                PRIMARY KEY (fkEmailCustomer, fkAddress)
);


CREATE TABLE Orders (
                pkOrder INT NOT NULL,
                OrderNo INT NOT NULL,
                fkEmailCustomer INT NOT NULL,
                fkAddress INT NOT NULL,
                fkDistributor INT NOT NULL,
                PRIMARY KEY (pkOrder)
);

ALTER TABLE Orders MODIFY COLUMN OrderNo INTEGER COMMENT '7 digit order reference number';

ALTER TABLE Orders MODIFY COLUMN fkAddress INTEGER COMMENT 'Customer''s selected shipping address for this order';

ALTER TABLE Orders MODIFY COLUMN fkDistributor INTEGER COMMENT 'Distributor who will fulfill this order (serving shipping address)';


CREATE TABLE Orders_Wines (
                fkOrder INT NOT NULL,
                fkWine INT NOT NULL,
                PRIMARY KEY (fkOrder, fkWine)
);


ALTER TABLE Wines ADD CONSTRAINT lookupunits_wines_fk
FOREIGN KEY (fkCaseUnit)
REFERENCES LookupCaseUnits (pkCaseUnit)
ON DELETE NO ACTION
ON UPDATE NO ACTION;

ALTER TABLE Wines ADD CONSTRAINT producers_wines_fk
FOREIGN KEY (fkProducer)
REFERENCES Producers (pkProducer)
ON DELETE NO ACTION
ON UPDATE NO ACTION;

ALTER TABLE Orders ADD CONSTRAINT distributors_orders_fk
FOREIGN KEY (fkDistributor)
REFERENCES Distributors (pkDistributor)
ON DELETE NO ACTION
ON UPDATE NO ACTION;

ALTER TABLE EmailCustomers_ShippingAddresses ADD CONSTRAINT addresses_emailcustomers_address_fk
FOREIGN KEY (fkAddress)
REFERENCES Addresses (pkAddress)
ON DELETE NO ACTION
ON UPDATE NO ACTION;

ALTER TABLE Orders_Wines ADD CONSTRAINT wines_orders_wines_fk
FOREIGN KEY (fkWine)
REFERENCES Wines (pkWine)
ON DELETE NO ACTION
ON UPDATE NO ACTION;

ALTER TABLE EmailCustomers_ShippingAddresses ADD CONSTRAINT emailcustomers_emailcustomers_address_fk
FOREIGN KEY (fkEmailCustomer)
REFERENCES EmailCustomers (pkEmailCustomer)
ON DELETE NO ACTION
ON UPDATE NO ACTION;

ALTER TABLE EmailCustomerPhoneNumbers ADD CONSTRAINT emailcustomers_emailcustomerphonenumbers_fk
FOREIGN KEY (fkEmailCustomer)
REFERENCES EmailCustomers (pkEmailCustomer)
ON DELETE NO ACTION
ON UPDATE NO ACTION;

ALTER TABLE EmailCustomerCreditCards ADD CONSTRAINT emailcustomers_emailcustomercreditcards_fk
FOREIGN KEY (fkEmailCustomer)
REFERENCES EmailCustomers (pkEmailCustomer)
ON DELETE NO ACTION
ON UPDATE NO ACTION;

ALTER TABLE Orders ADD CONSTRAINT emailcustomers_orders_fk
FOREIGN KEY (fkEmailCustomer)
REFERENCES EmailCustomers (pkEmailCustomer)
ON DELETE NO ACTION
ON UPDATE NO ACTION;

ALTER TABLE Orders ADD CONSTRAINT emailcustomers_shippingaddresses_orders_fk
FOREIGN KEY (fkEmailCustomer, fkAddress)
REFERENCES EmailCustomers_ShippingAddresses (fkEmailCustomer, fkAddress)
ON DELETE NO ACTION
ON UPDATE NO ACTION;

ALTER TABLE Orders_Wines ADD CONSTRAINT orders_orders_wines_fk
FOREIGN KEY (fkOrder)
REFERENCES Orders (pkOrder)
ON DELETE NO ACTION
ON UPDATE NO ACTION;
