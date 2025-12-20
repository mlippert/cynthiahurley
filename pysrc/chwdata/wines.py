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
import time
import logging
import re

# Third party imports

# Local application imports
from .chw_db import CHW_DB, mariadb
from .chw_sql import CHW_SQL


default_update_user = 'Gillian'


class InterruptWithBlock(UserWarning):
    """
    To be used to interrupt the march of a with
    see StackOverflow answer https://stackoverflow.com/a/69859356/2184226
    and `with suppress(InterruptWithBlock) as _` use below
    """


class Wines(CHW_DB):
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

    # Constants used to configure the Wine SQL statements
    DB_CNTR_DATADIR = '/tmp/data/infiles/'
    LEGACY_WINE_CSV_FILENAME = 'WineMasterTable_12-18-xform.csv'
    LEGACY_WINE_TABLE_SUFFIX = '_1218'

    def __init__(self, **kwargs):
        """
        Initialize the Wines class, setting initial values for all instance variables

        Specify the keyword parameter to override the default values of:
        domain, port, db_name, db_user, db_password
        """
        super().__init__(**kwargs)
        self.logger = logging.getLogger('CynthiaHurleyDB.Wines')

    def load_legacy_table_from_csv(self):
        """
        Load the LegacyWineMaster_1106 table from the
        WineMasterTable_11-06-xform.csv csv file mapped into
        the mariadb container's /tmp/data/infiles/ directory
        """
        sql = CHW_SQL.get_legacy_wine_master_load_data({'suffix':  Wines.LEGACY_WINE_TABLE_SUFFIX,
                                                        'csvfile': Wines.LEGACY_WINE_CSV_FILENAME,
                                                        'datadir': Wines.DB_CNTR_DATADIR})

        try:
            with (self._connection.cursor() as legacy_wines_load_data_cursor):
                t = time.process_time()
                legacy_wines_load_data_cursor.execute(sql)
                exectime = time.process_time() - t
                rows_affected = legacy_wines_load_data_cursor.rowcount
                warnings = legacy_wines_load_data_cursor.warnings
                print(f'Load Data successful, {rows_affected} rows affected, {warnings} warnings ({exectime:.3f} secs)')

            self._connection.commit()
        except mariadb.DataError as e:
            print(type(e))
            print(e.args)
            print(e)
            print(sql)
            raise e from None

    def create_producers_from_legacy(self):
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

        re_year = re.compile(r'\d{4}$')
        re_decade = re.compile(r'\d{4}s$')

        legacy_wines_by_producer_sql = CHW_SQL.get_legacy_wines_by_producer_sql({'suffix':  Wines.LEGACY_WINE_TABLE_SUFFIX})

        with (self._connection.cursor() as legacy_wines_by_producer_cursor,
              self._connection.cursor(prepared=True) as insert_producer_cursor,
              self._connection.cursor(prepared=True) as insert_producer_legacywine_cursor):

            starttime = time.process_time()
            producers_added = 0
            producer_note_cnt = 0
            legacy_wines_by_producer_cursor.execute(legacy_wines_by_producer_sql)
            last_producer_name = ''
            last_producer_id = -1
            prev_producer_description = ''

            for producer_wine_row in legacy_wines_by_producer_cursor:
                # When the producer changes, process the new producer
                producer_name = producer_wine_row[ProducerName]
                wine_id = producer_wine_row[WineId]
                producer_description = producer_wine_row[ProducerDescription]
                conversion_notes = None

                if producer_name != last_producer_name:
                    # Insert new Producer record
                    producer_code = producer_wine_row[ProducerCode]
                    year_established = producer_wine_row[YearEstablished].strip()

                    if re_year.match(year_established) is not None:
                        year_established = int(year_established)
                    elif year_established == '':
                        year_established = None
                    elif re_decade.match(year_established) is not None:
                        year_established = int(year_established[:4])
                        conversion_notes = 'year established is decade'

                    new_producer = (producer_name,
                                    producer_description,
                                    None if producer_code == '' else producer_code,
                                    year_established,
                                   )

                    try:
                        insert_producer_cursor.execute(CHW_SQL.insert_producer_sql, new_producer)
                        producers_added += 1
                    except mariadb.DataError as e:
                        print(type(e))
                        print(e.args)
                        print(e)
                        print(new_producer)
                        raise e from None

                    last_producer_id = insert_producer_cursor.lastrowid
                    last_producer_name = producer_name
                    prev_producer_description = producer_description

                if producer_description != prev_producer_description:
                    conversion_notes = 'Description changed'

                if conversion_notes is not None:
                    producer_note_cnt += 1

                producer_legacywine = (last_producer_id, wine_id, conversion_notes)
                insert_producer_legacywine_cursor.execute(CHW_SQL.insert_producer_legacywine_sql,
                                                          producer_legacywine)
                prev_producer_description = producer_description

            exectime = time.process_time() - starttime
            print(f'Insert producers from legacy successful, {producers_added} rows affected, {producer_note_cnt} notes ({exectime:.3f} secs)')

        self._connection.commit()

    def setup_lookup_table_records(self):
        """
        Initialize the Wine related Lookup tables
        - LookupWineColors
        - LookupWineTypes
        - LookupCaseUnits
        - LookupWineCountries
        - LookupWineRegions
        - LookupWineSubregions
        - LookupWineAppellations
        """
        # TODO: set this flag from a parameter
        show_warnings = False
        init_lookup_table_stmts = (('LookupWineColors', CHW_SQL.insert_lookup_wine_colors_sql),
                                   ('LookupWineTypes', CHW_SQL.insert_lookup_wine_types_sql),
                                   ('LookupCaseUnits', CHW_SQL.insert_lookup_case_units_sql),
                                   ('LookupWineCountries', CHW_SQL.insert_lookup_wine_countries_sql),
                                   ('LookupWineRegions', CHW_SQL.insert_lookup_wine_regions_sql),
                                   ('LookupWineSubregions', CHW_SQL.insert_lookup_wine_subregions_sql),
                                   ('LookupWineAppellations', CHW_SQL.insert_lookup_wine_appellations_sql),
                                  )

        with (self._connection.cursor() as init_lookup_table_cursor):
            for table_name, sql in init_lookup_table_stmts:
                init_lookup_table_cursor.execute(sql)

                rows_affected = init_lookup_table_cursor.rowcount
                warnings = init_lookup_table_cursor.warnings
                print(f'Init table {table_name} successful, {rows_affected} rows affected, {warnings} warnings')
                if show_warnings and warnings > 0:
                    self.print_cursor_warnings(init_lookup_table_cursor)

                init_lookup_table_cursor.connection.commit()

    def create_wines_from_legacy(self):
        """
        Create wine records in the Wines table from the LegacyWineMaster

        Producer records must have already been created and lookup tables
        populated.
        """
        # TODO: set this flag from a parameter
        show_warnings = True

        sql = CHW_SQL.get_insert_wines_from_legacy_sql({'suffix':  Wines.LEGACY_WINE_TABLE_SUFFIX})

        try:
            with (self._connection.cursor() as insert_wines_from_legacy_cursor):
                t = time.process_time()
                insert_wines_from_legacy_cursor.execute(sql)
                exectime = time.process_time() - t

                rows_affected = insert_wines_from_legacy_cursor.rowcount
                warnings = insert_wines_from_legacy_cursor.warnings
                print(f'Insert wines from legacy successful, {rows_affected} rows affected, {warnings} warnings ({exectime:.3f} secs)')
                if show_warnings and warnings > 0:
                    self.print_cursor_warnings(insert_wines_from_legacy_cursor)

            self._connection.commit()
        except mariadb.Error as e:
            print(type(e))
            print(e.args)
            print(e)
            print(sql)
            # We don't need the stacktrace output, so don't reraise the exception
            # raise e from None

    @staticmethod
    def print_cursor_warnings(cursor):
        """
        Print the warnings from the last execution of the given cursor
        """
        for severity, code, msg in cursor.connection.show_warnings():
            print(severity, code, msg)


# Public action functions to be called by the CLI


def do_load_legacy_wine_master_from_csv():
    wines = Wines()
    wines.load_legacy_table_from_csv()


def do_create_producers_from_legacy():
    wines = Wines()
    wines.create_producers_from_legacy()


def do_setup_lookup_table_records():
    wines = Wines()
    wines.setup_lookup_table_records()


def do_create_wines_from_legacy():
    wines = Wines()
    wines.create_wines_from_legacy()


def _test():
    pass


if __name__ == '__main__':
    _test()
