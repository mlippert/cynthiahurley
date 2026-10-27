"""
################################################################################
  new_wine.py
################################################################################

This module provides methods to operate on the new chw schema's wine tables

Python naming convention reminder note: single underscore prefix class names are
for "private" internal use and should not be considered part of the public API.

=============== ================================================================
Created on      October 8, 2026
--------------- ----------------------------------------------------------------
author(s)       Michael Jay Lippert
--------------- ----------------------------------------------------------------
Copyright       (c) 2026-present Michael Jay Lippert
                MIT License (see https://opensource.org/licenses/MIT)
=============== ================================================================
"""

# Standard library imports
import time
import logging

# Third party imports

# Local application imports
from .chw_db import mariadb
from .chw_sql import CHW_SQL


class InterruptWithBlock(UserWarning):
    """
    To be used to interrupt the march of a with
    see StackOverflow answer https://stackoverflow.com/a/69859356/2184226
    and `with suppress(InterruptWithBlock) as _` use below
    """


class NewWine:
    """
    An instance of NewWine is created with a live connector to a MariaDB
    chw database to be worked on.

    The methods will operate on the Wine tables in that database. Inserting,
    Updating, Deleting and querying information along with queries against
    the LegacyWineMaster table.

    Information can be returned about:

    - Wines
      - Name, item numbers, prices, producers, etc.
    """

    # packaging suffixes found in the legacy wine FullName column
    # DevNote: these are sorted in descending length so the longer suffixes get removed 1st
    _packaging_suffixes = ('(375 ml x 12-pack)',
                           '(375ml x 12-pack)',
                           '(375ml x 24-pack)',
                           '(750ml x 12-pack)',
                           '250ml Cans 24pk',
                           '250ml Cans 48pk',
                           '1.5L three-pack',
                           '1.5L six-pack',
                           'MAG 1.5L 6pk',
                           '3L BIB (6pk)',
                           '500ml (6pk)',
                           '1.5L (3pk)',
                           '1.5L (6pk)',
                           '1.5 (3pk)',
                           '1.5 (6pk)',
                           'six-pack',
                           '(375ml)',
                           '(6 pk)',
                           '6 pack',
                           '6 Pack',
                           '(12pk)',
                           '(1pk)',
                           '(3pk)',
                           '(6pk)',
                           '375ml',
                           '500ml',
                           '1.5L',
                           '6pk',
                           '3L',
                           '6L',
                          )

    def __init__(self, connecction):
        """
        Initialize the NewWine class, setting initial values for all instance variables

        Specify the keyword parameter to override the default values of:
        domain, port, db_name, db_user, db_password
        """
        self.logger = logging.getLogger('CynthiaHurleyDB.NewWine')

        self._connection = connecction

        self._insert_wine_cursor = None
        self._insert_wine_legacywine_cursor = None

    def __enter__(self):
        """
        Allocate resources (cursors) when entering a with block
        """
        # Using binary protocol (prepared statements) for better performance with repeated queries.
        self._insert_wine_cursor = self._connection.cursor(binary=True)
        self._insert_wine_legacywine_cursor = self._connection.cursor(binary=True)

        return self

    def __exit__(self, exc_type, exc_value, traceback):
        """
        Deallocate resources (cursors) that were allocated when entering a with block
        """
        self._insert_wine_cursor.close()
        self._insert_wine_cursor = None
        self._insert_wine_legacywine_cursor.close()
        self._insert_wine_legacywine_cursor = None

    def legacy_wines(self, params):
        """
        A generator method that returns LegacyWineMaster rows with the columns
        named in CHW_SQL.Col_legacy_wines_by_winecode using the latest row for
        each unique wine_code.

        The query gives the Wine columns and ALL of the WineItem records that are
        in the legacy table, sorted such that we return the values in the first
        of each Wine identified by WineCode.

        Producer records must have already been created and lookup tables
        populated.
        """
        # Alias column indices enum for clarity
        Col = CHW_SQL.Col_legacy_wines_by_winecode

        sql = CHW_SQL.get_select_wines_from_legacy_sql(params)

        try:
            with (self._connection.cursor() as select_wines_from_legacy_cursor):
                select_wines_from_legacy_cursor.execute(sql)

                last_wine_code = ''
                for wine_row in select_wines_from_legacy_cursor:
                    # When the wine_code changes, the legacy row is a new wine
                    wine_code = wine_row[Col.WineCode]
                    if wine_code != last_wine_code:
                        # yield the row as representing the new legacy wine
                        yield wine_row
                        last_wine_code = wine_code

        except mariadb.Error as e:
            print(type(e))
            print(e.args)
            print(e)
            print(sql)
            # We don't need the stacktrace output, so don't reraise the exception
            # raise e from None

    def insert_wine_from_legacy(self, legacy_wine_row):
        """
        Insert new Wine record using values from the given wine_row

        :param legacy_wine_row: The row from the select_wines_from_legacy_cursor with the
                                values for creating the new Wine record.
                                ex: (3113, 'F1010', '25240001000298', None, 'Tradition Pinot Blanc Pensée',
                                     1, 1, 0, 'Pinot Blanc', 1, 1, None, 1, None, '', '', '', '', 0,
                                     'France: Alsace', datetime.date(2026, 6, 5),
                                     datetime.datetime(2026, 8, 18, 16, 48, 51))
        :type legacy_wine_row: tuple[int, str, str, str, str, int, int, bool, str, int, int, int, int,
                                     int, str, str, str, str, bool, str, date, timestamp]

        :return: the wine_id of the created Wine record
        :rtype: int
        """
        # Alias column indices enum for clarity
        Col = CHW_SQL.Col_legacy_wines_by_winecode

        wine_name = legacy_wine_row[Col.WineName]

        if wine_name is None:
            wine_name = legacy_wine_row[Col.FullName]

        # some wine names or full names have trailing whitespace which will mess up the suffix removal
        wine_name = wine_name.strip()

        # strip off any packaging suffixes (including any in the existing WineName field)
        for suffix in self._packaging_suffixes:
            wine_name = wine_name.removesuffix(suffix)

        # strip leading and trailing whitespace
        wine_name = wine_name.strip()

        new_wine = (legacy_wine_row[Col.WineCode],
                    legacy_wine_row[Col.COLA_TTB_ID],
                    legacy_wine_row[Col.UPC],
                    wine_name,
                    legacy_wine_row[Col.WineColorId],
                    legacy_wine_row[Col.WineTypeId],
                    legacy_wine_row[Col.CertifiedOrganic],
                    legacy_wine_row[Col.Varietals],
                    legacy_wine_row[Col.WineCountryId],
                    legacy_wine_row[Col.WineRegionId],
                    legacy_wine_row[Col.WineSubregionId],
                    legacy_wine_row[Col.WineAppellationId],
                    legacy_wine_row[Col.ProducerId],
                    legacy_wine_row[Col.ShelfTalkerText],
                    legacy_wine_row[Col.TastingNotes],
                    legacy_wine_row[Col.Vinification],
                    legacy_wine_row[Col.TerroirVineyardPractices],
                    legacy_wine_row[Col.EndOfWine],
                    legacy_wine_row[Col.PriceListSectionId],
                    legacy_wine_row[Col.Created],
                    legacy_wine_row[Col.LastModified],
                   )

        try:
            self._insert_wine_cursor.execute(CHW_SQL.insert_wine_sql, new_wine)
            wine_id = self._insert_wine_cursor.lastrowid

            wine_legacywine = (wine_id,
                               legacy_wine_row[Col.WineItemId])

            self._insert_wine_legacywine_cursor.execute(CHW_SQL.insert_wine_legacywine_sql, wine_legacywine)

        except mariadb.DataError as e:
            print(type(e))
            print(e.args)
            print(e)
            print(new_wine)
            raise e from None

        return wine_id

    def insert_matching_complianceinfo_from_legacy(self, params):
        """
        Create wine compliance records in the WineComplianceInfo table from the
        LegacyWineMaster records that were used to create the Wines records

        :param params: dictionary of keyword parameters used to format the sql string
                       used. Only needs suffix of the current LegacyWineMaster table. e.g. '_0824'
        :type params: {'suffix': str}
        """
        # TODO: set this flag from a parameter
        show_warnings = True

        sql = CHW_SQL.get_insert_winecomplianceinfo_from_legacy_sql(params)

        try:
            with (self._connection.cursor() as insert_winecompliance_from_legacy_cursor):
                t = time.process_time()
                insert_winecompliance_from_legacy_cursor.execute(sql)
                exectime = time.process_time() - t

                rows_affected = insert_winecompliance_from_legacy_cursor.rowcount
                warnings = insert_winecompliance_from_legacy_cursor.warnings
                print(('Insert wine compliance info from legacy successful, '
                       f'{rows_affected} rows affected, {warnings} warnings ({exectime:.3f} secs)'))
                if show_warnings and warnings > 0:
                    CHW_SQL.print_cursor_warnings(insert_winecompliance_from_legacy_cursor)

            self._connection.commit()
        except mariadb.Error as e:
            print(type(e))
            print(e.args)
            print(e)
            print(sql)
            # We don't need the stacktrace output, so don't reraise the exception
            # raise e from None
