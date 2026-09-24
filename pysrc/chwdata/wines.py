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
    LEGACY_WINE_CSV_FILENAME = 'WineMasterTable_08-24-xform.csv'
    LEGACY_WINE_TABLE_SUFFIX = '_0824'

    # Regular expressions for parsing values in the legacy wine columns
    re_year = re.compile(r'\d{4}$')
    re_decade = re.compile(r'\d{4}s$')

    def __init__(self, **kwargs):
        """
        Initialize the Wines class, setting initial values for all instance variables

        Specify the keyword parameter to override the default values of:
        domain, port, db_name, db_user, db_password
        """
        super().__init__(**kwargs)
        self.logger = logging.getLogger('CynthiaHurleyDB.Wines')

        # Cursors for _init_producers_from_legacy_cursors()
        # DevNote: pylint was giving me an error when I tried to put these in a dict
        #          E1133: Non-iterable value is used in an iterating context (not-an-iterable)
        self._legacy_wines_by_producer_cursor = None
        self._insert_producer_cursor = None
        self._insert_producer_loa_cursor = None
        self._insert_producer_loa_authorized_state_cursor = None
        self._insert_producer_legacywine_cursor = None

    def load_legacy_table_from_csv(self):
        """
        Load the LegacyWineMaster_1124 table from the
        WineMasterTable_11-24-xform.csv csv file mapped into
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
        Note: As of Aug 2026 all LegacyWineMaster records have been given a producer code
              that identifies the wine producer. The other producer fields may still differ
              from one wine record to the next.

        Create producers from LegacyWineMaster
        - Find all unique ProducerCodes
        For each ProducerCode
          - find all WineMaster records with that ProducerCode sorted by LastUpdated descending
            use the ProducerName, ProducerDescription, ProducerCode, YearEstablished and Exporter
            from the first (ie most recently updated) WineMaster record to create a new Producer record.
        - INSERT Producer record using values from the
          from the first WineMaster record to create a new Producer record.
        - INSERT a Producers_LegacyWineMaster record for EVERY LegacyWineMaster record which
          has that unique ProducerCode. Add a conversion note if the name, description, or
          year established changed from the previous record.
        """
        # Alias column indices enum for clarity
        Col = CHW_SQL.Col_legacy_wines_by_producer

        legacy_wines_by_producer_sql = CHW_SQL.get_legacy_wines_by_producer_sql({'suffix':  Wines.LEGACY_WINE_TABLE_SUFFIX})

        try:
            self._init_producers_from_legacy_cursors()

            starttime = time.process_time()
            producers_added = 0
            producer_note_cnt = 0
            self._legacy_wines_by_producer_cursor.execute(legacy_wines_by_producer_sql)
            last_producer_code = ''
            last_producer_id = -1
            prev_producer_name = ''
            prev_producer_description = ''

            for producer_wine_row in self._legacy_wines_by_producer_cursor:
                # When the producer changes, process the new producer
                producer_code = producer_wine_row[Col.ProducerCode]
                wine_id = producer_wine_row[Col.WineId]
                producer_name = producer_wine_row[Col.ProducerName]
                producer_description = producer_wine_row[Col.ProducerDescription]
                conversion_notes = []

                if producer_code != last_producer_code:
                    # Insert new Producer record
                    last_producer_id = self._create_new_producer_from_legacy_row(producer_wine_row, conversion_notes)
                    producers_added += 1

                    # last_ is last new producer record created, while prev_ is the previous legacy record
                    last_producer_code = producer_code

                    # prev_ values are used for conversion notes to record when the producer name/description
                    # changed from the previous legacy wine record for that producer. As this is
                    # the 1st record for this producer, there is no change to note
                    prev_producer_name = producer_wine_row[Col.ProducerName]
                    prev_producer_description = producer_wine_row[Col.ProducerDescription]

                if producer_name != prev_producer_name:
                    conversion_notes += ['Producer name changed']

                if producer_description != prev_producer_description:
                    conversion_notes += ['Description changed']

                if conversion_notes:
                    producer_note_cnt += 1

                producer_legacywine = (last_producer_id,
                                       wine_id,
                                       ', '.join(conversion_notes) if conversion_notes else None)
                self._insert_producer_legacywine_cursor.execute(CHW_SQL.insert_producer_legacywine_sql,
                                                                producer_legacywine)
                prev_producer_name = producer_name
                prev_producer_description = producer_description

            exectime = time.process_time() - starttime
            print(('Insert producers from legacy successful, '
                   f'{producers_added} rows affected, {producer_note_cnt} notes ({exectime:.3f} secs)'))

        finally:
            self._close_producers_from_legacy_cursors()

        self._connection.commit()

    def _init_producers_from_legacy_cursors(self):
        """
        Initialize all instance cursors used while creating producer records
        from the legacy wine master
        """
        self._legacy_wines_by_producer_cursor = self._connection.cursor()
        self._insert_producer_cursor = self._connection.cursor(binary=True)
        self._insert_producer_loa_cursor = self._connection.cursor(binary=True)
        self._insert_producer_loa_authorized_state_cursor = self._connection.cursor(binary=True)
        self._insert_producer_legacywine_cursor = self._connection.cursor(binary=True)

    def _close_producers_from_legacy_cursors(self):
        """
        Close all instance cursors initialized by _init_producers_from_legacy_cursors
        """
        self._legacy_wines_by_producer_cursor.close()
        self._legacy_wines_by_producer_cursor = None
        self._insert_producer_cursor.close()
        self._insert_producer_cursor = None
        self._insert_producer_loa_cursor.close()
        self._insert_producer_loa_cursor = None
        self._insert_producer_loa_authorized_state_cursor.close()
        self._insert_producer_loa_authorized_state_cursor = None
        self._insert_producer_legacywine_cursor.close()
        self._insert_producer_legacywine_cursor = None

    def _create_new_producer_from_legacy_row(self, producer_wine_row, conversion_notes):
        """
        Insert new Producer record using values from the given producer_wine_row

        Note: _init_producers_from_legacy_cursors() must have been called before this method

        :param producer_wine_row: The row from the _legacy_wines_by_producer_cursor with the
                                  values for creating the new Producer record.
        :type producer_wine_row: tuple[int, str, str, str, str, str, date, str, bool, str, date]

        :param conversion_notes: List of conversion notes, that may have new notes appended to it.
        :type conversion_notes: list[str]

        :return: the producer_id of the created Producer record
        """
        # Alias column indices enum for clarity
        Col = CHW_SQL.Col_legacy_wines_by_producer

        producer_code = producer_wine_row[Col.ProducerCode]
        producer_name = producer_wine_row[Col.ProducerName]
        producer_description = producer_wine_row[Col.ProducerDescription]
        year_established = producer_wine_row[Col.YearEstablished].strip()
        exporter = producer_wine_row[Col.Exporter].strip()

        if Wines.re_year.match(year_established) is not None:
            year_established = int(year_established)
        elif year_established == '':
            year_established = None
        elif Wines.re_decade.match(year_established) is not None:
            year_established = int(year_established[:4])
            conversion_notes += ['year established is decade']

        new_producer = (producer_code,
                        producer_name,
                        producer_description,
                        year_established,
                        None if exporter == '' else exporter,
                       )

        try:
            self._insert_producer_cursor.execute(CHW_SQL.insert_producer_sql, new_producer)
        except mariadb.DataError as e:
            print(type(e))
            print(e.args)
            print(e)
            print(new_producer)
            raise e from None

        producer_id = self._insert_producer_cursor.lastrowid
        self._create_new_producer_loa_from_legacy_row(producer_id, producer_wine_row)
        return producer_id

    def _create_new_producer_loa_from_legacy_row(self, producer_id, producer_wine_row):
        """
        Insert new ProducerLOA record for the given producer_id using values from
        the given producer_wine_row

        Note: _init_producers_from_legacy_cursors() must have been called before this method

        :param producer_id: The producer Id of the Producer record that the LOA record(s) are
                            related to.
        :type producer_id: int

        :param producer_wine_row: The row from the _legacy_wines_by_producer_cursor with the
                                  values for creating the new Producer record.
        :type producer_wine_row: tuple[int, str, str, str, str, str, date, str, bool, str, date]
        """
        # Alias column indices enum for clarity
        Col = CHW_SQL.Col_legacy_wines_by_producer

        loa_date = producer_wine_row[Col.LOA_Date]
        if loa_date is None:
            return

        loa_comment = producer_wine_row[Col.LOA_Comment]
        multiple_loas = producer_wine_row[Col.Multiple_LOAs]
        states_authorized = producer_wine_row[Col.StatesAuthorized]
        state_authorization_confirmation_date = producer_wine_row[Col.StatesAuthConfirmationDate]

        new_producer_loa = (producer_id,
                            loa_date,
                            loa_comment,
                            multiple_loas,
                            state_authorization_confirmation_date,
                           )

        try:
            self._insert_producer_loa_cursor.execute(CHW_SQL.insert_producer_loa_sql, new_producer_loa)
        except mariadb.DataError as e:
            print(type(e))
            print(e.args)
            print(e)
            print(new_producer_loa)
            raise e from None

        for state_postal_abbrev in states_authorized.split():
            try:
                self._insert_producer_loa_authorized_state_cursor.execute(
                    CHW_SQL.insert_producer_loa_authorized_state_sql,
                    (producer_id, state_postal_abbrev))
            except mariadb.DataError as e:
                print(type(e))
                print(e.args)
                print(e)
                print(new_producer_loa)
                raise e from None

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
        - LookupUSStates
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
                                   ('LookupUSStates', CHW_SQL.insert_lookup_us_states_sql),
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
                print(('Insert wines from legacy successful, '
                       f'{rows_affected} rows affected, {warnings} warnings ({exectime:.3f} secs)'))
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

    def create_winepricing_from_legacy(self):
        """
        Create wine records in the WinePricing table from the LegacyWineMaster
        """
        # TODO: set this flag from a parameter
        show_warnings = True

        sql = CHW_SQL.get_insert_winepricing_from_legacy_sql({'suffix':  Wines.LEGACY_WINE_TABLE_SUFFIX})

        try:
            with (self._connection.cursor() as insert_winepricing_from_legacy_cursor):
                t = time.process_time()
                insert_winepricing_from_legacy_cursor.execute(sql)
                exectime = time.process_time() - t

                rows_affected = insert_winepricing_from_legacy_cursor.rowcount
                warnings = insert_winepricing_from_legacy_cursor.warnings
                print(('Insert winepricing from legacy successful, '
                       f'{rows_affected} rows affected, {warnings} warnings ({exectime:.3f} secs)'))
                if show_warnings and warnings > 0:
                    self.print_cursor_warnings(insert_winepricing_from_legacy_cursor)

            self._connection.commit()
        except mariadb.Error as e:
            print(type(e))
            print(e.args)
            print(e)
            print(sql)
            # We don't need the stacktrace output, so don't reraise the exception
            # raise e from None

    def create_winepurchases_from_legacy(self):
        """
        Create wine records in the WinePurchases table from the LegacyWineMaster
        """
        # TODO: set this flag from a parameter
        show_warnings = True

        sql = CHW_SQL.get_insert_winepurchases_from_legacy_sql({'suffix':  Wines.LEGACY_WINE_TABLE_SUFFIX})

        try:
            with (self._connection.cursor() as insert_winepurchases_from_legacy_cursor):
                t = time.process_time()
                insert_winepurchases_from_legacy_cursor.execute(sql)
                exectime = time.process_time() - t

                rows_affected = insert_winepurchases_from_legacy_cursor.rowcount
                warnings = insert_winepurchases_from_legacy_cursor.warnings
                print(('Insert winepurchases from legacy successful, '
                       f'{rows_affected} rows affected, {warnings} warnings ({exectime:.3f} secs)'))
                if show_warnings and warnings > 0:
                    self.print_cursor_warnings(insert_winepurchases_from_legacy_cursor)

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


def do_create_winepricing_from_legacy():
    wines = Wines()
    wines.create_winepricing_from_legacy()


def do_create_winepurchases_from_legacy():
    wines = Wines()
    wines.create_winepurchases_from_legacy()


def _test():
    pass


if __name__ == '__main__':
    _test()
