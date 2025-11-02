"""
################################################################################
  chwdata.retail_orders.py
################################################################################

This module provides access to the Retail Order tables, and to the
LegacyEmailOrders table from the chw database

Python naming convention reminder note: single underscore prefix class names are
for "private" internal use and should not be considered part of the public API.

=============== ================================================================
Created on      October 10, 2025
--------------- ----------------------------------------------------------------
author(s)       Michael Jay Lippert
--------------- ----------------------------------------------------------------
Copyright       (c) 2025-present Michael Jay Lippert
                MIT License (see https://opensource.org/licenses/MIT)
=============== ================================================================
"""

# Standard library imports
import sys
import logging
import pprint
from datetime import timedelta, date

# Third party imports
import mariadb

# Local application imports

default_domain = '127.0.0.1'
default_port = 3306
default_db_name = 'chw'
default_db_user = 'chwuser'
default_db_password = 'cynthiahurley'
default_update_user = 'Gillian'

# Task 1: Create retail customers from LegacyEmailOrders
#  - Find all unique FullName's which are not empty.
#  - For each unique full name create a new EmailCustomer
#  - Attempt to parse the full name into an optional Title, a given name and a surname
#    - Convert all consecutive whitespace into a single space character
#    - Strip leading and trailing non-alphanumeric characters
#    - Split into words on space characters
#    - Check 1st word to see if it is a known title (Mr. Mrs. Ms. Dr., etc.)
#        if so set EmailCustomer title field and shift words (2nd becomes 1st, etc)
#    - Check last word for known suffixes ((Jr. II, III, MD)
#        if so WHAT?
#    - If 2 words assume 1st is given name and 2nd is surname and set them
#      ALSO set flag for manual review to FALSE in the EmailCustomers_LegacyEmailsOrders table
#    - Otherwise if more than 2 words, set given name to all words except last joined by spaces,
#      and set surname to the last word.
#      ALSO set flag for manual review to TRUE in the EmailCustomers_LegacyEmailsOrders table
#
#  - INSERT EmailCustomer record (get the assigned EmailCustomerId (HOW? cursor.lastrowid))
#  - INSERT an EmailCustomers_LegacyEmailOrders record for EVERY LegacyEmailOrders record which
#    has that unique FullName.
#
#


class RetailOrders:
    """
    An instance of RetailOrders is created with the MariaDB
    domain, port and db name of the chw database to
    be worked on.

    The methods will operate on that database. Inserting,
    Updating, Deleting and querying information from the
    tables in that database.

    Information can be returned about:

    - Email customers and their orders
    - Wines
      - Name, item numbers, prices, producers, etc.
    - Producers
    """

    # format strings for the objects returned by Riffdata methods
    meeting_fmt = ('meeting ({_id}) "{title}" in room {room}\n'
                   '{startTime:%Y %b %d %H:%M} — {endTime:%H:%M} ({meetingLengthMin:.1f} minutes)\n'
                   '{participant_cnt} participants:'
                  )

    # Select statement to retrieve unique fullnames from
    _unique_fullname_sql = ('SELECT FullName, COUNT( FullName ) NumOrders '
                            ' FROM chw.LegacyEmailOrders_1002'
                            ' WHERE FullName != \'\''
                            ' GROUP BY FullName'
                            ' ORDER BY FullName ASC'
                           )

    _unique_fullname_sql2 = ('SELECT DISTINCT FullName'
                             ' FROM chw.LegacyEmailOrders_1002'
                             ' WHERE FullName != \'\''
                             ' ORDER BY FullName ASC'
                            )

    # Select statement for Customer columns of ALL LegacyEmailOrders records with a matching FullName
    _legacy_customer_info_columns = ('EmailOrderId',
                                     'FirstDate',
                                     'FullName',
                                     'LastName',
                                     'Email1',
                                     'CompanyAptNo',
                                     'Street',
                                     'City',
                                     'State',
                                     'Zip',
                                     'PhoneHome',
                                     'PhoneWork',
                                     'FaxNumber',
                                     'CCVisa',
                                     'CCAmex',
                                     'CCMastercard',
                                     'CC_ID'
                                    )
    _legacy_customer_info_sql = ('SELECT ' + ', '.join(_legacy_customer_info_columns) +
                                 ' FROM chw.LegacyEmailOrders_1002'
                                 ' WHERE FullName = ?'
                                 ' ORDER BY FirstDate ASC'
                                )

    # Insert statement to create EmailCustomer record
    _insert_email_customer_sql = ('INSERT INTO chw.EmailCustomers '
                                  ' (Title'
                                  ', GivenName'
                                  ', Surname'
                                  ', Suffix'
                                  ', Email'
                                  ', Created'
                                  ', CreatedBy'
                                  ', LastModified'
                                  ', LastModifiedBy'
                                  ')'
                                  ' VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)'
                                 )

    # Insert statement to create EmailCustomers_LegacyEmailOrders record
    _insert_customer_legacyorder_sql = ('INSERT INTO chw.EmailCustomers_LegacyEmailOrders '
                                        ' (EmailCustomerId'
                                        ', EmailOrderId'
                                        ', NameNeedsReview'
                                        ', EmailNeedsReview'
                                        ', ConversionNotes'
                                        ')'
                                        ' VALUES (?, ?, ?, ?, ?)'
                                       )

    _orders_of_top_customers_columns = ('EC.EmailCustomerId,',
                                        'EC.GivenName',
                                        'EC.Surname',
                                        'EC.Email',
                                        'LEO.FirstDate OrderDate',
                                        'LEO.DelItemss',
                                        'LEO.DelItem2',
                                        'LEO.DelItem3',
                                        'LEO.DelItem4',
                                        'LEO.DelItem5',
                                        'LEO.Vintage',
                                        'LEO.Vintage2',
                                        'LEO.Vintage3',
                                        'LEO.Vintage4',
                                        'LEO.Vintage5',
                                        'LEO.Quantity',
                                        'LEO.Quant2',
                                        'LEO.Quant3',
                                        'LEO.Quant4',
                                        'LEO.Quant5'
                                       )

    _orders_of_top_customers2_sql = ('SELECT ' + ', '.join(_orders_of_top_customers_columns) +
                                    'FROM chw.EmailCustomers EC'
                                    'JOIN chw.EmailCustomers_LegacyEmailOrders EC_LEO'
                                    '  ON EC.EmailCustomerId = EC_LEO.EmailCustomerId'
                                    'JOIN chw.LegacyEmailOrders_1002 LEO'
                                    '  ON LEO.EmailOrderId = EC_LEO.EmailOrderId'
                                    'WHERE EC.EmailCustomerId IN'
                                    '(10946, 10500, 10770, 11155, 9313, 13635, 10858, 12396, 13028, 11719, 11050, 13786, 11383, 11979, 11630, 9600, 11646)'
                                    'ORDER BY EC.EmailCustomerId ASC, OrderDate ASC'
                                   )

    _top_customers_emails = ('kcweiner@texcrude.com',
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
                            )
    _orders_of_top_customers_sql = ('SELECT EC.EmailCustomerId'
                                         ', EC.GivenName'
                                         ', EC.Surname'
                                         ', EC.Email'
                                         ', LEO.PhoneHome'
                                         ', LEO.FirstDate OrderDate'
                                         ', U.EmailOrderId'
                                         ', U.Item'
                                         ', U.Vintage'
                                         ', U.Quantity'
                                   ' FROM ((SELECT EmailOrderId, DelItemss AS Item, Vintage, Quantity'
                                          ' FROM LegacyEmailOrders_1002'
                                          ' WHERE DelItemss != \'\''
                                          ')'
                                         ' UNION ALL'
                                         ' (SELECT EmailOrderId, DelItem2, Vintage2, Quant2'
                                          ' FROM LegacyEmailOrders_1002'
                                          ' WHERE DelItem2 != \'\''
                                          ')'
                                         ' UNION ALL'
                                         ' (SELECT EmailOrderId, DelItem3, Vintage3, Quant3'
                                          ' FROM LegacyEmailOrders_1002'
                                          ' WHERE DelItem3 != \'\''
                                          ')'
                                         ' UNION ALL'
                                         ' (SELECT EmailOrderId, DelItem4, Vintage4, Quant4'
                                          ' FROM LegacyEmailOrders_1002'
                                          ' WHERE DelItem4 != \'\''
                                          ')'
                                         ' UNION ALL'
                                         ' (SELECT EmailOrderId, DelItem5, Vintage5, Quant5'
                                          ' FROM LegacyEmailOrders_1002'
                                          ' WHERE DelItem5 != \'\''
                                          ')'
                                         ') AS U'
                                   ' JOIN LegacyEmailOrders_1002 AS LEO ON U.EmailOrderId = LEO.EmailOrderId'
                                   ' JOIN EmailCustomers_LegacyEmailOrders AS EC_LEO ON U.EmailOrderId = EC_LEO.EmailOrderId'
                                   ' JOIN EmailCustomers AS EC ON EC_LEO.EmailCustomerId = EC.EmailCustomerId'
                                   ' WHERE EC.Email IN (\'' + '\', \''.join(_top_customers_emails) + '\')' +
                                   ' OR (EC.GivenName = \'Alexander\' AND EC.Surname = \'Kinsey\')'
                                   ' ORDER BY Email ASC, OrderDate ASC'
                                   )

    def __init__(self, *,
                 domain=default_domain,
                 port=default_port,
                 db_name=default_db_name,
                 db_user=default_db_user,
                 db_password=default_db_password):
        """
        Initialize the RetailOrders class, setting initial values for all instance variables
        """
        self.logger = logging.getLogger('CynthiaHurleyDB.RetailOrders')

        self._db_config = {'host':     domain,
                           'port':     port,
                           'user':     db_user,
                           'password': db_password,
                           'database': db_name
                          }
        try:
            self._connection = mariadb.connect(**self._db_config)
        except mariadb.Error as e:
            print(f"An error occurred: {e}")
            print('mariadb.onnect arguments:', self._db_config)
            sys.exit(1)

    def __del__(self):
        """
        Close the connection to the database
        """
        if self._connection:
            self._connection.close()
            print("Connection closed.", file=sys.stderr)

    def create_customers_from_legacy(self, update_user=default_update_user):
        """
        Create retail customers from LegacyEmailOrders
        - Find all unique FullName's which are not empty.
        - For each unique full name create a new EmailCustomer
        - Attempt to parse the full name into an optional Title, a given name and a surname
          - Convert all consecutive whitespace into a single space character
          - Strip leading and trailing non-alphanumeric characters
          - Split into words on space characters
          - Check 1st word to see if it is a known title (Mr. Mrs. Ms. Dr., etc.)
              if so set EmailCustomer title field and shift words (2nd becomes 1st, etc)
          - Check last word for known suffixes ((Jr. II, III, MD)
              if so WHAT?
          - If 2 words assume 1st is given name and 2nd is surname and set them
            ALSO set flag for manual review to FALSE in the EmailCustomers_LegacyEmailsOrders table
          - Otherwise if more than 2 words, set given name to all words except last joined by spaces,
            and set surname to the last word.
            ALSO set flag for manual review to TRUE in the EmailCustomers_LegacyEmailsOrders table

        - INSERT EmailCustomer record (get the assigned EmailCustomerId (HOW? cursor.lastrowid))
        - INSERT an EmailCustomers_LegacyEmailOrders record for EVERY LegacyEmailOrders record which
          has that unique FullName.
        """
        with (self._connection.cursor() as unique_fullname_cursor,
              self._connection.cursor(prepared=True) as legacy_customer_info_cursor,
              self._connection.cursor(prepared=True) as insert_email_customer_cursor,
              self._connection.cursor(prepared=True) as insert_customer_legacyorder_cursor):

            #print(RetailOrders._unique_fullname_sql, file=sys.stdout)
            #print(RetailOrders._legacy_customer_info_sql, file=sys.stdout)
            #print(RetailOrders._insert_email_customer_sql, file=sys.stdout)
            #print(RetailOrders._insert_customer_legacyorder_sql, file=sys.stdout)

            customer_count = 0
            needs_review = 0
            unique_fullname_cursor.execute(RetailOrders._unique_fullname_sql)
            for fullname_row in unique_fullname_cursor:
                # Parse name into title, given_name, surname, suffix, manual_review_needed
                parsed_name = self.parse_fullname(fullname_row[0])

                # Get Legacy order records for fullname
                legacy_customer_info_cursor.execute(RetailOrders._legacy_customer_info_sql, (fullname_row[0],))

                # TODO: for now we'll just use the FirstDate and Email1 from the 1st legacy order
                #       as the values for the new email customer record
                customer_info = self._get_customer_info_from_legacy_orders(legacy_customer_info_cursor)

                # Insert new Email Customer record
                new_email_customer = (parsed_name['title'],
                                      parsed_name['given_name'],
                                      parsed_name['surname'],
                                      parsed_name['suffix'],
                                      None if len(customer_info['email']) == 0 else customer_info['email'][0],
                                      customer_info['first_order_date'] if customer_info['first_order_date'] is not None else date(1970, 1, 1),
                                      update_user,
                                      customer_info['last_order_date'] if customer_info['last_order_date'] is not None else date(1970, 1, 1),
                                      update_user
                                     )

                #print(new_email_customer, file=sys.stdout)
                insert_email_customer_cursor.execute(RetailOrders._insert_email_customer_sql, new_email_customer)
                customer_id = insert_email_customer_cursor.lastrowid
                name_needs_review = parsed_name['manual_review_needed']
                email_needs_review = customer_info['email_needs_review']
                conversion_notes = ('Email was changed in order ids: '
                                    + ', '.join([str(id) for id in customer_info['email_changed_orderids']])
                                    if len(customer_info['email_changed_orderids']) > 0 else None)
                for order_id in customer_info['order_ids']:
                    customer_legacyorder = (customer_id,
                                            order_id,
                                            name_needs_review,
                                            email_needs_review,
                                            conversion_notes
                                           )
                    #print(customer_legacyorder, file=sys.stdout)
                    insert_customer_legacyorder_cursor.execute(RetailOrders._insert_customer_legacyorder_sql,
                                                               customer_legacyorder)

                #f = sys.stdout
                #f.write(f'  {"":4} < {b[0]:4}: {b[1]:4}\n')
                #print(new_email_customer, file=sys.stdout)
                #print('!!' if parsed_name['manual_review_needed'] else '--',
                #      fullname_row[0], '-->',
                #      'T:"' + parsed_name['title'] + '"' if parsed_name['title'] is not None else '',
                #      'F:"' + parsed_name['given_name'] + '"',
                #      'L:"' + parsed_name['surname'] + '"',
                #      'S:"' + parsed_name['suffix'] + '"' if parsed_name['suffix'] is not None else '',
                #      'E:', customer_info['email'],
                #      file=sys.stdout)

                customer_count += 1
                needs_review += 1 if parsed_name['manual_review_needed'] else 0

            print('Total customers:', customer_count, 'Needs review:', needs_review)
        self._connection.commit()

    def write_top_customer_order_report(self):
        """
        TODO: this belongs in a different module, easier here for now though. -mjl 2025-10-31
        """

        # File to write report to (TODO make a parameter, for now just stdout)
        f = sys.stdout

        # Column indices
        EmailCustomerId = 0
        GivenName       = 1
        Surname         = 2
        Email           = 3
        PhoneHome       = 4
        OrderDate       = 5
        EmailOrderId    = 6
        Item            = 7
        Vintage         = 8
        Quantity        = 9

        customer_item_report_header = '''
## {1} {2}
|                  |                                |
| ---------------: | :----------------------------- |
| **Email:**       | {3!s:30} |
| **H Phone:**     | {4!s:30} |
| **Customer ID:** | {0!s:30} |
|                  |                                |

| Order Date / ID    | Item                                                     | Vintage | Quantity |
| :----------------- | :------------------------------------------------------- | ------: | :------- |
'''

        customer_item_report_new_order = '| {5} / {6:>5} | {7:56} | {8!s:>7} | {9:8} |\n'
        customer_item_report_add_item  = '|                    | {7:56} | {8!s:>7} | {9:8} |\n'

        with self._connection.cursor() as top_customer_order_items_cursor:
            top_customer_order_items_cursor.execute(RetailOrders._orders_of_top_customers_sql)

            # Write out Report header
            f.write('# Items Ordered by Customer\n\n')

            prev_customer_id = cur_customer_id = None
            prev_order_id = cur_order_id = None
            for customer_order_row in top_customer_order_items_cursor:
                # Check for customer change
                if customer_order_row[EmailCustomerId] != prev_customer_id:
                    # Write out header info for changed customer
                    f.write(customer_item_report_header.format(*customer_order_row))

                    # save current customer id as previous
                    prev_customer_id = customer_order_row[EmailCustomerId]

                # Check for order change
                order_fmt = customer_item_report_add_item
                if customer_order_row[EmailOrderId] != prev_order_id:
                    # switch the order fmt to include the order info column
                    order_fmt = customer_item_report_new_order

                    # save current order id as previous
                    prev_order_id = customer_order_row[EmailOrderId]

                # write the item ordered
                f.write(order_fmt.format(*customer_order_row))

            # Write a final blank line to end the final item table in the markdown report
            f.write('\n')

    @classmethod
    def _get_customer_info_from_legacy_orders(cls, legacy_customer_info_cursor):
        """
        Get additional customer information such as email, and shipping addresses from
        for the given cursor of Legacy Order records of the customer of interest (matching
        a particular FullName). The cursor should be positioned such that it will iterate
        over all of the customers orders.
        """

        # return object to contain values parsed from the legacy order records
        customer_info = {'order_ids':              [],
                         'email':                  [],
                         'email_needs_review':     False,
                         'email_changed_orderids': [],
                         'first_order_date':       date(1970, 1, 1),
                         'last_order_date':        date(1970, 1, 1)
                        }

        # TODO: for now we'll just use the FirstDate and Email1 from the 1st legacy order
        #       as the values for the new email customer record
        column_names = cls._legacy_customer_info_columns

        # get the first order (we expect them to be sorted ascending by FirstDate)
        # and there MUST be at least one to have extracted the fullname from
        customer_info_row = legacy_customer_info_cursor.fetchone()
        curEmail1 = customer_info_row[column_names.index('Email1')]
        customer_info['order_ids'] += [customer_info_row[column_names.index('EmailOrderId')]]
        # NOTE: I think FirstDate is the order date
        customer_info['first_order_date'] = customer_info_row[column_names.index('FirstDate')]
        customer_info['last_order_date'] = customer_info['first_order_date']

        prevEmail1 = curEmail1

        for customer_info_row in legacy_customer_info_cursor:
            customer_info['order_ids'] += [customer_info_row[column_names.index('EmailOrderId')]]
            customer_info['last_order_date'] = customer_info_row[column_names.index('FirstDate')]

            curEmail1 = customer_info_row[column_names.index('Email1')]
            if curEmail1 != prevEmail1:
                customer_info['email_needs_review'] = True
                customer_info['email_changed_orderids'] += [customer_info_row[column_names.index('EmailOrderId')]]

            prevEmail1 = curEmail1

        customer_info['email'] = RetailOrders.get_email_addresses(prevEmail1)
        customer_info['email_needs_review'] = len(customer_info['email']) > 1

        return customer_info

    @staticmethod
    def parse_fullname(fullname):
        """
        Attempt to parse the given freeform fullname into a given name and surname,
        along with a preferred title and suffix if those values are found.
        The name parts will be returned in a dictionary with keys:
        'title', 'given_name', 'surname', 'suffix' and 'manual_review_needed'

        This will be done by:
          - Converting all consecutive whitespace into a single space character
          - Stripping leading and trailing non-alphanumeric characters
          - Splitting into words on space characters
          - Check 1st word to see if it is a known title (Mr. Mrs. Ms. Dr., etc.)
              if so set EmailCustomer title field and shift words (2nd becomes 1st, etc)
          - Check last word for known suffixes ((Jr. II, III, MD)
              if so WHAT?
          - If 2 words assume 1st is given name and 2nd is surname and set them
            ALSO set flag for manual review to FALSE in the EmailCustomers_LegacyEmailsOrders table
          - Otherwise set given name to all words except last joined by spaces,
            and set surname to the last word. Note 1 word sets only the surname and 0 words sets
            neither, leaving the unset fields set to the empty string.
            ALSO set flag for manual review to TRUE in the EmailCustomers_LegacyEmailsOrders table
        """

        # return object to contain values parsed from given fullname
        name_parts = {'title':      None,
                      'given_name': '',
                      'surname':    '',
                      'suffix':     None,
                      'manual_review_needed': True}

        name_words = fullname.split()

        if (len(name_words) >= 1 and RetailOrders.is_name_title(name_words[0])):
            name_parts['title'] = name_words[0]
            del name_words[0]

        if (len(name_words) >= 1 and RetailOrders.is_name_suffix(name_words[-1])):
            name_parts['suffix'] = name_words[-1]
            del name_words[-1]

        # concatenate all remaining words except the last one into the given_name
        # put the last word in the surname (as long as there is at least 1 word)
        if len(name_words) > 0:
            name_parts['given_name'] = ' '.join(name_words[0:-1])
            name_parts['surname'] = name_words[-1]
            name_parts['manual_review_needed'] = len(name_words) != 2

        return name_parts

    @staticmethod
    def is_name_title(name):
        """
        Determine if the supplied name is a known title
        """

        # list of known titles
        # TODO: Consider if we want to check for several variations and always return
        #       a canonical version, ie match case insensitive with trailing '.' stripped
        #       to 'mr' would return 'Mr.', similarly 'ms', 'mrs', 'dr'
        known_titles = ('Mr', 'Mr.', 'Ms', 'Ms.', 'Mrs', 'Mrs.', 'Dr', 'Dr.')

        return name in known_titles

    @staticmethod
    def is_name_suffix(name):
        """
        Determine if the supplied name is a known suffix
        """

        # list of known suffixes
        # TODO: Consider if we want to check for several variations and always return
        #       a canonical version, ie match case insensitive with trailing '.' stripped
        #       to 'jr' would return 'Jr.', similarly 'iii', 'md'
        known_suffixes = ('Jr', 'Jr.', 'II', 'III', '111', 'MD')

        return name in known_suffixes

    @staticmethod
    def get_email_addresses(email_field):
        """
        Extract all email addresses from the given email field.
        Any "word" in the field which contains an '@' is considered an email address
        """

        email_words = email_field.split()
        emails = [email for email in email_words if '@' in email]

        # TODO: do we need to report back other conditions which might warrant review
        # such as more words than email addresses

        return emails


class Wines:
    """
    An instance of Wines is created with the MariaDB
    domain, port and db name of the chw database to
    be worked on.

    The methods will operate on that database. Inserting,
    Updating, Deleting and querying information from the
    tables in that database.

    Information can be returned about:

    - Wines
      - Name, item numbers, prices, producers, etc.
    """

    def __init__(self, *, domain=default_domain, port=default_port, db_name=default_db_name):
        """
        """
        self.logger = logging.getLogger('CynthiaHurleyDB.Wines')

        self._db_config = {'host':     domain,
                           'port':     port,
                           'user':     'chwuser',
                           'password': 'cynthiahurley',
                           'database': db_name
                          }
        self._connection = mariadb.connect(**self._db_config)


def do_create_customers_from_legacy(user):
    retailOrders = RetailOrders()
    retailOrders.create_customers_from_legacy()

def do_write_top_customer_order_report():
    retailOrders = RetailOrders()
    retailOrders.write_top_customer_order_report()


# Following is just the copied example from:
# https://mariadb.com/docs/connectors/connectors-quickstart-guides/connector-python-guide

# 1. Database Connection Parameters
db_config = {
    'host': 'localhost',
    'port': 3306,
    'user': 'chwuser',
    'password': 'cynthiahurley',
    'database': 'chw'
}


def run_db_operations():
    conn = None
    cursor = None
    try:
        # 2. Establish a Connection
        print("Connecting to MariaDB...")
        conn = mariadb.connect(**db_config)
        print("Connection successful!")

        # 3. Create a Cursor Object
        cursor = conn.cursor()

        # --- Example: Create a Table (if it doesn't exist) ---
        try:
            cursor.execute("""
                CREATE TABLE IF NOT EXISTS users (
                    id INT AUTO_INCREMENT PRIMARY KEY,
                    name VARCHAR(255) NOT NULL,
                    email VARCHAR(255) UNIQUE
                )
            """)
            conn.commit()  # Commit the transaction for DDL
            print("Table 'users' created or already exists.")
        except mariadb.Error as e:
            print(f"Error creating table: {e}")
            conn.rollback()  # Rollback in case of DDL error

        # --- Example: Insert Data (Parameterized Query) ---
        print("\nInserting data...")
        insert_query = "INSERT INTO users (name, email) VALUES (?, ?)"
        try:
            cursor.execute(insert_query, ("Alice Wonderland", "alice@example.com"))
            cursor.execute(insert_query, ("Bob Builder", "bob@example.com"))
            conn.commit()  # Commit the transaction for DML
            print(f"Inserted {cursor.rowcount} rows.")
            print(f"Last inserted ID: {cursor.lastrowid}")
        except mariadb.IntegrityError as e:
            print(f"Error inserting data (might be duplicate email): {e}")
            conn.rollback()
        except mariadb.Error as e:
            print(f"Error inserting data: {e}")
            conn.rollback()

        # --- Example: Select Data ---
        print("\nSelecting data...")
        select_query = "SELECT id, name, email FROM users WHERE name LIKE ?"
        cursor.execute(select_query, ("%Alice%",))  # Note the comma for single parameter tuple

        print("Fetched data:")
        for row in cursor:
            print(f"ID: {row[0]}, Name: {row[1]}, Email: {row[2]}")

        # --- Example: Update Data ---
        print("\nUpdating data...")
        update_query = "UPDATE users SET name = ? WHERE email = ?"
        cursor.execute(update_query, ("Alicia Wonderland", "alice@example.com"))
        conn.commit()
        print(f"Rows updated: {cursor.rowcount}")

        # --- Example: Delete Data ---
        print("\nDeleting data...")
        delete_query = "DELETE FROM users WHERE name = ?"
        cursor.execute(delete_query, ("Bob Builder",))
        conn.commit()
        print(f"Rows deleted: {cursor.rowcount}")

    except mariadb.Error as e:
        print(f"An error occurred: {e}")
        sys.exit(1)
    finally:
        # 4. Close Cursor and Connection
        if cursor:
            cursor.close()
            print("Cursor closed.")
        if conn:
            conn.close()
            print("Connection closed.")

#if __name__ == "__main__":
#    run_db_operations()


def _test():
    pass


if __name__ == '__main__':
    _test()
