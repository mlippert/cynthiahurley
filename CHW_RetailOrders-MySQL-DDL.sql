
CREATE TABLE LookupCCIssuers (
                pkCCIssuer TINYINT AUTO_INCREMENT NOT NULL,
                Name VARCHAR(20) NOT NULL,
                PRIMARY KEY (pkCCIssuer)
);

ALTER TABLE LookupCCIssuers MODIFY COLUMN Name VARCHAR(20) COMMENT 'Name of Issuer; Visa, MC, Discover, Amex, etc.';


CREATE TABLE LookupCaseUnits (
                pkCaseUnit TINYINT NOT NULL,
                Name VARCHAR(30) NOT NULL,
                PRIMARY KEY (pkCaseUnit)
);

ALTER TABLE LookupCaseUnits MODIFY COLUMN Name VARCHAR(30) COMMENT 'Description of the Unit, e.g. Bottle 750ml, Can 20oz, Box 500ml';


CREATE TABLE Producers (
                pkProducer INT NOT NULL,
                Name VARCHAR(200) NOT NULL,
                Region VARCHAR(100) NOT NULL,
                PRIMARY KEY (pkProducer)
);

ALTER TABLE Producers COMMENT 'A wine producer';


CREATE TABLE Distributors (
                pkDistributor INT NOT NULL,
                Name VARCHAR(200) NOT NULL,
                Email VARCHAR(200) NOT NULL,
                PRIMARY KEY (pkDistributor)
);

ALTER TABLE Distributors COMMENT 'The distributor is responsible for getting the order to the email customer';


CREATE TABLE Addresses (
                pkAddress INT NOT NULL,
                Street VARCHAR(150) NOT NULL,
                Street2 VARCHAR(150),
                City VARCHAR(100) NOT NULL,
                State VARCHAR(100) NOT NULL,
                PostalCode VARCHAR(30) NOT NULL,
                PRIMARY KEY (pkAddress)
);

ALTER TABLE Addresses MODIFY COLUMN Street2 VARCHAR(150) COMMENT 'optional 2nd Street line for address';

ALTER TABLE Addresses MODIFY COLUMN PostalCode VARCHAR(30) COMMENT 'zipcode in USA';


CREATE TABLE Wines (
                pkWine INT NOT NULL,
                ItemNo VARCHAR(10) NOT NULL,
                Name VARCHAR(100) NOT NULL,
                Vintage SMALLINT NOT NULL,
                fkProducer INT NOT NULL,
                Available BOOLEAN NOT NULL,
                SoldOut BOOLEAN NOT NULL,
                UnitsPerCase SMALLINT NOT NULL,
                fkCaseUnit TINYINT NOT NULL,
                PRIMARY KEY (pkWine)
);

ALTER TABLE Wines MODIFY COLUMN Vintage SMALLINT COMMENT '4 digit year';

ALTER TABLE Wines MODIFY COLUMN Available BOOLEAN COMMENT 'If a wine is not available it should be excluded from the list of wines for sale (True(1)-available, False(0)-excluded)';

ALTER TABLE Wines MODIFY COLUMN SoldOut BOOLEAN COMMENT 'True(1)-sold out, False(0)-in stock';

ALTER TABLE Wines MODIFY COLUMN UnitsPerCase SMALLINT COMMENT 'Units of wine include various size bottles, boxes and cans
Retail sales are sometimes by case and sometimes by unit';

ALTER TABLE Wines MODIFY COLUMN fkCaseUnit TINYINT COMMENT 'Type of unit in a case of this wine';


CREATE TABLE EmailCustomers (
                pkEmailCustomer INT NOT NULL,
                Created DATETIME NOT NULL,
                CreatedBy VARCHAR(30) NOT NULL,
                LastModified DATETIME NOT NULL,
                LastModifiedBy VARCHAR(30) NOT NULL,
                FirstName VARCHAR(100) NOT NULL,
                LastName VARCHAR(100) NOT NULL,
                Email VARCHAR(200) NOT NULL,
                PRIMARY KEY (pkEmailCustomer)
);


CREATE TABLE EmailCustomerCreditCards (
                fkEmailCustomer INT NOT NULL,
                pkN TINYINT NOT NULL,
                fkCCIssuer TINYINT NOT NULL,
                CardNumber VARCHAR(20) NOT NULL,
                ExpDate DATE NOT NULL,
                SecurityCode SMALLINT NOT NULL,
                PRIMARY KEY (fkEmailCustomer, pkN)
);

ALTER TABLE EmailCustomerCreditCards MODIFY COLUMN pkN TINYINT COMMENT 'pkN makes this a unique creditcard record pk for the email customer';

ALTER TABLE EmailCustomerCreditCards MODIFY COLUMN ExpDate DATE COMMENT 'Expiration Month and Year (DoM is not used)';

ALTER TABLE EmailCustomerCreditCards MODIFY COLUMN SecurityCode SMALLINT COMMENT 'Security code 3 digits (TODO, probably should not be stored)';


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


ALTER TABLE EmailCustomerCreditCards ADD CONSTRAINT lookupccissuers_emailcustomercreditcards_fk
FOREIGN KEY (fkCCIssuer)
REFERENCES LookupCCIssuers (pkCCIssuer)
ON DELETE NO ACTION
ON UPDATE NO ACTION;

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
