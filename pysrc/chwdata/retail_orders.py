"""
################################################################################
  chwdata.retail_orders.py
################################################################################

This module retrieves provides access to the Retail Order tables, and to the
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
                                  ' (Title,'
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
    _insert_email_customer_sql = ('INSERT INTO chw.EmailCustomers_LegacyEmailOrders '
                                  ' (EmailCustomerId,'
                                  ', EmailOrderId'
                                  ', NameNeedsReview'
                                  ', EmailNeedsReview'
                                  ', ConversionNotes'
                                  ')'
                                  ' VALUES (?, ?, ?, ?, ?)'
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
            print("Connection closed.")

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
              self._connection.cursor(prepared=True) as insert_email_customer_cursor):

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
                                      customer_info['email'],
                                      customer_info['first_order_date'],
                                      update_user,
                                      customer_info['last_order_date'],
                                      update_user
                                     )

                # for now don't insert just write to stdout
                #insert_email_customer_cursor.execute(RetailOrders._insert_email_customer_sql, new_email_customer)
                #f = sys.stdout
                #f.write(f'  {"":4} < {b[0]:4}: {b[1]:4}\n')
                #print(new_email_customer, file=sys.stdout)
                #print('!!' if parsed_name['manual_review_needed'] else '--',
                #      fullname_row[0], '-->',
                #      'T:"' + parsed_name['title'] + '"' if parsed_name['title'] is not None else '',
                #      'F:"' + parsed_name['given_name'] + '"',
                #      'L:"' + parsed_name['surname'] + '"',
                #      'S:"' + parsed_name['suffix'] + '"' if parsed_name['suffix'] is not None else '',
                #      file=sys.stdout)

                customer_count += 1
                needs_review += 1 if parsed_name['manual_review_needed'] else 0

            print('Total customers:', customer_count, 'Needs review:', needs_review)

    @classmethod
    def _get_customer_info_from_legacy_orders(cls, legacy_customer_info_cursor):
        """
        Get additional customer information such as email, and shipping addresses from
        for the given cursor of Legacy Order records of the customer of interest (matching
        a particular FullName). The cursor should be positioned such that it will iterate
        over all of the customers orders.
        """

        # return object to contain values parsed from the legacy order records
        customer_info = {'email':                  None,
                         'email_needs_review':     True,
                         'email_changed_orderids': [],
                         'first_order_date':       date(1970, 1, 1),
                         'last_order_date':        date(1970, 1, 1)
                        }

        # TODO: for now we'll just use the FirstDate and Email1 from the 1st legacy order
        #       as the values for the new email customer record
        column_names = cls._legacy_customer_info_columns
        customer_info_row = legacy_customer_info_cursor.fetchone()
        customer_info['email'] = customer_info_row[column_names.index('Email1')]
        customer_info['first_order_date'] = customer_info_row[column_names.index('FirstDate')]
        customer_info['last_order_date'] = customer_info['first_order_date']

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
