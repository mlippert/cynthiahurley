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
from contextlib import suppress

# Third party imports
import mariadb

# Local application imports

default_domain = '127.0.0.1'
default_port = 3306
default_db_name = 'chw'
default_db_user = 'chwuser'
default_db_password = 'cynthiahurley'
default_update_user = 'Gillian'



class InterruptWithBlock(UserWarning):
    """
    To be used to interrupt the march of a with
    see StackOverflow answer https://stackoverflow.com/a/69859356/2184226
    and `with suppress(InterruptWithBlock) as _` use below
    """

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

    # Select statement to retrieve producer's wines ordered by producer then descending dates
    _legacy_wines_by_producer_sql = ('SELECT WineId'
                                     ', ProducerName'
                                     ', ProducerDescription'
                                     ', ProducerCode'
                                     ', YearEstablished'
                                     ' FROM chw.LegacyWineMaster_1106'
                                     ' ORDER BY ProducerName ASC, LastUpdated DESC'
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

    # Insert statement to create Producers_LegacyWineMaster record
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
        # Column indices
        WineId              = 0
        ProducerName        = 1
        ProducerDescription = 2
        ProducerCode        = 3
        YearEstablished     = 4

        with (self._connection.cursor() as legacy_wines_by_producer_cursor,
              self._connection.cursor(prepared=True) as insert_producer_cursor,
              self._connection.cursor(prepared=True) as insert_producer_legacywine_cursor):

            legacy_wines_by_producer_cursor.execute(Wines._legacy_wines_by_producer_sql)
            last_producer_name = ''
            last_producer_id = -1

            for producer_wine_row in legacy_wines_by_producer_cursor:
                # When the producer changes, process the new producer
                producer_name = producer_wine_row[ProducerName]
                wine_id = producer_wine_row[WineId]
                conversion_notes = None

                if producer_name != last_producer_name:
                    # Insert new Producer record
                    new_producer = (producer_name,
                                    producer_wine_row[ProducerDescription],
                                    producer_wine_row[ProducerCode],
                                    producer_wine_row[YearEstablished],
                                   )

                    insert_producer_cursor.execute(Wines._insert_producer_sql, new_producer)
                    last_producer_id = insert_producer_cursor.lastrowid
                    last_producer_name = producer_name
                    prev_producer_description = producer_wine_row[ProducerDescription]

                if producer_wine_row[ProducerDescription] != prev_producer_description:
                    conversion_notes = 'Description changed'

                producer_legacywine = (last_producer_id, wine_id, conversion_notes)
                insert_producer_legacywine_cursor.execute(Wines._insert_producer_legacywine_sql,
                                                          producer_legacywine)

        self._connection.commit()


# Public action functions to be called by the CLI

def do_create_producers_from_legacy(user):
    wines = Wines()
    wines.create_producers_from_legacy()


def _test():
    pass


if __name__ == '__main__':
    _test()
