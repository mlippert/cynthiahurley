/* To get permission to write to a file execute the following SQL statement AS the root user: */
GRANT FILE ON *.* TO chwuser;
/* Also change the folder permissions on the bound directory ie. chmod o+w data/infiles/ */

/*
 * Load the LegacyEmailOrders_NNNN table from a delimited file in the "infiles" directory
 * NNNN == 1106 as of the last update of the snippet
 */
LOAD DATA LOCAL INFILE '/tmp/data/infiles/EmailWineOrders_11-06-xform.csv'
REPLACE INTO TABLE LegacyEmailOrders_1106
FIELDS TERMINATED BY '|' OPTIONALLY ENCLOSED BY '"'
IGNORE 1 LINES
(
EmailOrderId,
OrderNumber,
@FirstDate,
FullName,
LastName,
CompanyAptNo,
Street,
City,
State,
Zip,
PhoneHome,
PhoneWork,
FaxNumber,
Email,
Email1,
Source,
SubPaid,
CCVisa,
CCAmex,
CCMastercard,
CC_ID,
TotalRetailCharge,
@Subtotal,
AdditionalCharges,
Retailer,
Quantity,
DelItems,
@Vintage,
Quant2,
DelItem2,
@Vintage2,
Quant3,
DelItem3,
@Vintage3,
Quant4,
DelItem4,
@Vintage4,
Quant5,
DelItem5,
@Vintage5,
CustDetails
)
SET
FirstDate=if(LENGTH(@FirstDate) < 9, NULL, @FirstDate),
Subtotal=if(@Subtotal = '', NULL, @Subtotal),
Vintage=if(@Vintage REGEXP '^[0-9]{4}$', @Vintage, NULL),
Vintage2=if(@Vintage2 REGEXP '^[0-9]{4}$', @Vintage2, NULL),
Vintage3=if(@Vintage3 REGEXP '^[0-9]{4}$', @Vintage3, NULL),
Vintage4=if(@Vintage4 REGEXP '^[0-9]{4}$', @Vintage4, NULL),
Vintage5=if(@Vintage5 REGEXP '^[0-9]{4}$', @Vintage5, NULL)
;

/* UPDATE LegacyEmailOrders_NNNN to set TotalRetailCharge to NULL for the new orders
where the new Subtotal and AdditionalCharges columns are used. TotalRetailCharge is not
seen and left at whatever value it had in the copied order that was modified to be the
new order.
*/
UPDATE LegacyEmailOrders_0219 SET TotalRetailCharge = NULL WHERE Subtotal IS NOT NULL;

/*
Notes about LegacyEmailOrders_1002
26511 Order Records
 4823 Distinct FullName
  371 FullName == ''
  187 FullName LIKE ' %' (starts with a space)
    1 FullName LIKE '\n%' (starts with a newline)
    9 FullName LIKE '%\n%' (contains a newline)
 2873 Distinct Email1
 5601 Email1 == ''
  155 Distinct Email1 LIKE ' %' (starts with a space)
    1 Distinct Email1 LIKE '\n%' (starts with a newline)
  226 Distinct Email1 LIKE '%\n%' (contains a newline)

 5437 Distinct FullName, Email1
 5148 Distinct FullName, Email1 with FullName != ''
 3139 Distinct FullName, Email1 with Email1 != ''
 2851 Distinct FullName, Email1 with FullName != '' AND Email1 != ''
 1287 Distinct FullName, Email1 with FullName != '' AND Email1 != '' AND NumberOfOrders > 1
  601 Distinct FullName, Email1 with FullName != '' AND Email1 != '' AND NumberOfOrders > 1 AND Year >= 2016

Query for that last follows:
*/
SELECT FullName, Email1, COUNT( FullName ) NumberOfOrders, YEAR( FirstDate ) Year
FROM chw.LegacyEmailOrders_1002
WHERE FullName != '' AND Email1 != '' AND YEAR( FirstDate ) >= 2016
GROUP BY FullName, Email1
HAVING NumberOfOrders > 1
ORDER BY FullName ASC
;

/* qryEmailOrdersWithTotalCharge */
SELECT EmailOrderId, FirstDate,
  TRIM(REPLACE(REPLACE(FullName, '\n', ' '), '\t', ' ')),
  TRIM(REPLACE(REPLACE(Email1, '\n', ' '), '\t', ' ')),
  TRIM(REPLACE(REPLACE(TotalRetailCharge, '\n', ' '), '\t', ' ')),
  Subtotal, AdditionalCharges
FROM LegacyEmailOrders_1106
WHERE TotalRetailCharge != ''
INTO OUTFILE '/tmp/data/infiles/EmailOrdersTotalCharges_11-06.tsv'
;

CREATE TABLE LegacyEmailOrdersTotals_1106 (
                EmailOrderId INT NOT NULL,
                TotalRetailCharge VARCHAR(101),
                Subtotal DECIMAL(8,2),
                AdditionalCharges VARCHAR(120),
                PRIMARY KEY (EmailOrderId)
);

LOAD DATA LOCAL INFILE '/tmp/data/infiles/EmailOrdersTotalCharges_11-06_SplitInNewFields.tsv'
REPLACE INTO TABLE LegacyEmailOrdersTotals_1106
FIELDS OPTIONALLY ENCLOSED BY '"'
(
EmailOrderId,
@FirstDate,
@FullName,
@Email1,
TotalRetailCharge,
@Subtotal,
AdditionalCharges
)
SET
Subtotal=if(@Subtotal = '', NULL, @Subtotal)
;

SELECT YEAR( EOrders.FirstDate ) AS Year, EOrders.FullName FullName, SUM( `EOTotals`.`Subtotal` ) AS Total
FROM chw.LegacyEmailOrders_1002 AS EOrders, chw.LegacyEmailOrdersTotals_1002 AS EOTotals
WHERE EOrders.EmailOrderId = EOTotals.EmailOrderId GROUP BY Year, FullName ORDER BY Year ASC, FullName ASC
;

SELECT
    YEAR( Orders.FirstDate ) Year,
    Orders.FullName,
    COUNT( Orders.FullName ) NumOrders,
    SUM( OrderTotals.Subtotal ) Total
FROM
    chw.LegacyEmailOrders_1002 Orders,
    chw.LegacyEmailOrdersTotals_1002 OrderTotals
WHERE OrderTotals.EmailOrderId = Orders.EmailOrderId
GROUP BY Orders.FullName, YEAR( Orders.FirstDate )
ORDER BY Year ASC, Total ASC
;

/* using JOIN syntax instead of WHERE */
SELECT
    YEAR( Orders.FirstDate ) Year,
    Orders.FullName,
    COUNT( Orders.FullName ) NumOrders,
    SUM( OrderTotals.Subtotal ) Total
FROM
    chw.LegacyEmailOrders_1002 Orders INNER JOIN chw.LegacyEmailOrdersTotals_1002 OrderTotals
    ON Orders.EmailOrderId = OrderTotals.EmailOrderId
GROUP BY Orders.FullName, YEAR( Orders.FirstDate )
ORDER BY Year ASC, Total ASC
;

/* Customers Since 2020 Total of all orders ever */
/* Customer Total orders since 2020 - Add WHERE clause YEAR(Orders.FirstDate) >= 2020 */
SELECT
    Orders.FullName, Orders.Email1,
    SUM( OrderTotals.Subtotal ) Total,
    MIN( YEAR( Orders.FirstDate ) ) YearOfFirstOrder,
    MAX( YEAR( Orders.FirstDate ) ) YearOfLastOrder,
    COUNT( Orders.FullName ) NumberOfOrders
FROM
    chw.LegacyEmailOrders_1002 Orders INNER JOIN chw.LegacyEmailOrdersTotals_1002 OrderTotals
    ON Orders.EmailOrderId = OrderTotals.EmailOrderId
GROUP BY Orders.FullName
HAVING ( ( YearOfLastOrder >= 2020 ) )
ORDER BY Total ASC, Orders.FullName ASC
;


SELECT
    EC.EmailCustomerId EmailCustomerId,
    EC.GivenName GivenName,
    EC.Surname Surname,
    EC.Email Email,
    LEO.FirstDate OrderDate,
    LEO.DelItemss Item
FROM chw.EmailCustomers EC
JOIN chw.EmailCustomers_LegacyEmailOrders EC_LEO
  ON EC.EmailCustomerId = EC_LEO.EmailCustomerId
JOIN chw.LegacyEmailOrders_1002 LEO
  ON LEO.EmailOrderId = EC_LEO.EmailOrderId
UNION ALL
(SELECT
    EC.EmailCustomerId,
    EC.GivenName,
    EC.Surname,
    EC.Email,
    LEO.FirstDate,
    LEO.DelItem2
FROM chw.EmailCustomers EC
JOIN chw.EmailCustomers_LegacyEmailOrders EC_LEO
  ON EC.EmailCustomerId = EC_LEO.EmailCustomerId
JOIN chw.LegacyEmailOrders_1002 LEO
  ON LEO.EmailOrderId = EC_LEO.EmailOrderId)
WHERE EC.EmailCustomerId IN
(10946,
10500,
10770,
11155,
9313,
13635,
10858,
12396,
13028,
11719,
11050,
13786,
11383,
11979)
ORDER BY EmailCustomerId ASC, OrderDate ASC

SELECT
    EC.EmailCustomerId,
    EC.GivenName,
    EC.Surname,
    EC.Email,
    LEO.FirstDate OrderDate,
    LEO.PhoneHome,
    LEO.DelItemss,
    LEO.DelItem2,
    LEO.DelItem3,
    LEO.DelItem4,
    LEO.DelItem5,
    LEO.Vintage,
    LEO.Vintage2,
    LEO.Vintage3,
    LEO.Vintage4,
    LEO.Vintage5,
    LEO.Quantity,
    LEO.Quant2,
    LEO.Quant3,
    LEO.Quant4,
    LEO.Quant5
FROM chw.EmailCustomers EC
JOIN chw.EmailCustomers_LegacyEmailOrders EC_LEO
  ON EC.EmailCustomerId = EC_LEO.EmailCustomerId
JOIN chw.LegacyEmailOrders_1002 LEO
  ON LEO.EmailOrderId = EC_LEO.EmailOrderId
WHERE EC.Email IN
(
'kcweiner@texcrude.com',
'Jack.Ende@uphs.upenn.edu',
'jchilds@jwchilds.com',
'lukecorsten@yahoo.com',
'Steve.Ezell@landcorp.com',
'Joseph.Losee@chp.edu',
'philip.mengel@gmail.com',
'njmoult@yahoo.com ',
'BCLindsay@aol.com',
'lewoolcott@gmail.com ',
'tpotter@capdale.com',
'michael.a.gangemi@gmail.com',
'wagner@clearbrookadvisors.com',
'alitt4383@aol.com',
'byronagrant@gmail.com',
'adupont@craneco.com'
)
ORDER BY EC.EmailCustomerId ASC, OrderDate ASC

SELECT EC.EmailCustomerId, EC.GivenName, EC.Surname, EC.Email, LEO.PhoneHome, LEO.FirstDate OrderDate, U.EmailOrderId, U.Item, U.Vintage, U.Quantity
FROM
((select EmailOrderId, DelItemss as Item, Vintage, Quantity from LegacyEmailOrders_1002 where DelItemss != '')
union all
(select EmailOrderId, DelItem2, Vintage2, Quant2 from LegacyEmailOrders_1002 where DelItem2 != '')
union all
(select EmailOrderId, DelItem3, Vintage3, Quant3 from LegacyEmailOrders_1002 where DelItem3 != '')
union all
(select EmailOrderId, DelItem4, Vintage4, Quant4 from LegacyEmailOrders_1002 where DelItem4 != '')
union all
(select EmailOrderId, DelItem5, Vintage5, Quant5 from LegacyEmailOrders_1002 where DelItem5 != '')) AS U
JOIN LegacyEmailOrders_1002 AS LEO ON U.EmailOrderId = LEO.EmailOrderId
JOIN EmailCustomers_LegacyEmailOrders AS EC_LEO ON U.EmailOrderId = EC_LEO.EmailOrderId
JOIN EmailCustomers AS EC ON EC_LEO.EmailCustomerId = EC.EmailCustomerId
WHERE EC.Email IN
(
'kcweiner@texcrude.com',
'Jack.Ende@uphs.upenn.edu',
'jchilds@jwchilds.com',
'lukecorsten@yahoo.com',
'Steve.Ezell@landcorp.com',
'Joseph.Losee@chp.edu',
'philip.mengel@gmail.com',
'njmoult@yahoo.com ',
'BCLindsay@aol.com',
'lewoolcott@gmail.com ',
'tpotter@capdale.com',
'michael.a.gangemi@gmail.com',
'wagner@clearbrookadvisors.com',
'alitt4383@aol.com',
'byronagrant@gmail.com',
'adupont@craneco.com',
'cis@mosbacherproperties.com',
'cek@mosbacherproperties.com'
) OR (EC.GivenName = 'Alexander' AND EC.Surname = 'Kinsey')
ORDER BY Email ASC, OrderDate ASC
INTO OUTFILE '/tmp/data/infiles/TopCustomersOrderItems_1002.tsv'
