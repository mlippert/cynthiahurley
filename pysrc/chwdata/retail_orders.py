"""
################################################################################
  chwdata.retail_orders.py
################################################################################

This module retrieves provides access to the Retail Order tables, and to the
LegacyEmailOrders table from the chw database

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
from datetime import timedelta

# Third party imports
import mariadb

# Local application imports

default_domain = 'localhost'
default_port = 3306
default_db_name = 'chw'
default_db_user = 'chwuser'
default_db_password = 'cynthiahurley'

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
        unique_fullname_sql = 'SELECT DISTINCT FullName'
                              ' FROM chw.LegacyEmailOrders_1002'
                              ' WHERE FullName != \'\''
                              ' ORDER BY FullName ASC'
                              ' ;'

    def __init__(self, *, domain=default_domain,
                          port=default_port,
                          db_name=default_db_name,
                          db_user=default_db_user,
                          db_password=default_db_password):
        """
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

    def __del__(self):
        """
        Close the connection to the database
        """
        if self._connection:
            self._connection.close()
            print("Connection closed.")



    def drop_db(self):
        """
        Drop the Riff Database.

        Obviously the database will need to be restored before any other operations
        will succeed.
        """
        self.client.drop_database(self.db)

    def create_customers_from_legacy(self):
        """
        """
        unique_fullname_cursor = self._connection.cursor()


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
            conn.commit() # Commit the transaction for DDL
            print("Table 'users' created or already exists.")
        except mariadb.Error as e:
            print(f"Error creating table: {e}")
            conn.rollback() # Rollback in case of DDL error

        # --- Example: Insert Data (Parameterized Query) ---
        print("\nInserting data...")
        insert_query = "INSERT INTO users (name, email) VALUES (?, ?)"
        try:
            cursor.execute(insert_query, ("Alice Wonderland", "alice@example.com"))
            cursor.execute(insert_query, ("Bob Builder", "bob@example.com"))
            conn.commit() # Commit the transaction for DML
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
        cursor.execute(select_query, ("%Alice%",)) # Note the comma for single parameter tuple

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
