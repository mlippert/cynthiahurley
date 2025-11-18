"""
################################################################################
  chwdata.wines.py
################################################################################

This module provides access to the Wines tables, and to the
LegacyWineMaster table from the chw database

Python naming convention reminder note: single underscore prefix class names are
for "private" internal use and should not be considered part of the public API.

=============== ================================================================
Created on      November 18, 2025
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

    # Select statement to retrieve unique fullnames from
    _unique_producer_sql = ('SELECT WineId'
                            ', ProducerName'
                            ', ProducerDescription'
                            ', ProducerCode'
                            ', YearEstablished'
                            ' FROM chw.LegacyWineMaster_1106'
                            ' ORDER BY ProducerName ASC, LastUpdated ASC'
                           )

    # Insert statement to create Producer record
    _insert_producer_sql = ('INSERT INTO chw.Producers'
                            ' (Nmae'
                            ', Description'
                            ', ProducerCode'
                            ', YearEstablished'
                            ')'
                            ' VALUES (?, ?, ?, ?)'
                           )

    # Insert statement to create EmailCustomers_LegacyEmailOrders record
    _insert_producer_legacywine_sql = ('INSERT INTO chw.Producers_LegacyWineMaster'
                                       ' (ProducerId'
                                       ', WineId'
                                       ', ConversionNotes'
                                       ')'
                                       ' VALUES (?, ?, ?)'
                                      )

    def __init__(self, *,
                 domain=default_domain,
                 port=default_port,
                 db_name=default_db_name,
                 db_user=default_db_user,
                 db_password=default_db_password):
        """
        Initialize the Wines class, setting initial values for all instance variables
        """
        self.logger = logging.getLogger('CynthiaHurleyDB.Wines')

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

    def create_producers_from_legacy(self, update_user=default_update_user):
        """
        Create producers from LegacyWineMaster
        - Find all unique ProducerNames
        For each ProducerName
          - find all WineMaster records with that ProducerName sorted by LastUpdated ascending
          - use the ProducerName, ProducerDescription, ProducerCode and YearEstablished from the last
          - WineMaster record to create a new Producer record.
        - INSERT Producer record using values from the
        - INSERT a Producers_LegacyWineMaster record for EVERY LegacyWineMaster record which
          has that unique ProducerName. Add a conversion note if the description, code or
          year established changed from the previous record.
        """
        with (self._connection.cursor() as unique_producername_cursor,
              self._connection.cursor(prepared=True) as legacy_producer_wine_cursor,
              self._connection.cursor(prepared=True) as insert_producer_cursor,
              self._connection.cursor(prepared=True) as insert_producer_legacywine_cursor):

            #print(RetailOrders._unique_fullname_sql, file=sys.stdout)
            #print(RetailOrders._legacy_customer_info_sql, file=sys.stdout)
            #print(RetailOrders._insert_email_customer_sql, file=sys.stdout)
            #print(RetailOrders._insert_customer_legacyorder_sql, file=sys.stdout)

            customer_count = 0
            needs_review = 0
            unique_producername_cursor.execute(Wines._unique_producer_sql)
            for producer_row in unique_producername_cursor:
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


# Public action functions to be called by the CLI

def do_create_customers_from_legacy(user):
    retailOrders = RetailOrders()
    retailOrders.create_customers_from_legacy()

def do_write_top_customer_order_report():
    retailOrders = RetailOrders()
    retailOrders.write_top_customer_order_report()


def _test():
    pass


if __name__ == '__main__':
    _test()
