"""
################################################################################
  new_wineitem.py
################################################################################

This module provides methods to operate on the new chw schema's wineitem tables

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


class NewWineItem:
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

    def __init__(self, connecction):
        """
        Initialize the NewWineItem class, setting initial values for all instance variables

        Specify the keyword parameter to override the default values of:
        domain, port, db_name, db_user, db_password
        """
        self.logger = logging.getLogger('CynthiaHurleyDB.NewWineItem')

        self._connection = connecction

        self._insert_winewholesalepricing_cursor = None
        self._insert_winewholesalecasebreaks_cursor = None

    def __enter__(self):
        """
        Allocate resources (cursors) when entering a with block
        """
        # Using binary protocol (prepared statements) for better performance with repeated queries.
        self._insert_winewholesalepricing_cursor = self._connection.cursor(binary=True)
        self._insert_winewholesalecasebreaks_cursor = self._connection.cursor(binary=True)

        return self

    def __exit__(self, exc_type, exc_value, traceback):
        """
        Deallocate resources (cursors) that were allocated when entering a with block
        """
        self._insert_winewholesalepricing_cursor.close()
        self._insert_winewholesalepricing_cursor = None
        self._insert_winewholesalecasebreaks_cursor.close()
        self._insert_winewholesalecasebreaks_cursor = None

    def insert_wineitems_from_legacy(self, params):
        """
        Insert new WineItem records with id's from the associated tables which
        must have been created from the LagacyWineMaster before calling this method.

        :param params: dictionary of keyword parameters used to format the sql string
                       used. Only needs suffix of the current LegacyWineMaster table. e.g. '_0824'
        :type params: {'suffix': str}

        :return: the number of rows inserted
        :rtype: int
        """
        # TODO: set this flag from a parameter
        show_warnings = True

        sql = CHW_SQL.get_insert_wineitems_from_legacy_sql(params)

        try:
            with (self._connection.cursor() as insert_wineitems_from_legacy_cursor):
                t = time.process_time()
                insert_wineitems_from_legacy_cursor.execute(sql)
                exectime = time.process_time() - t

                rows_affected = insert_wineitems_from_legacy_cursor.rowcount
                warnings = insert_wineitems_from_legacy_cursor.warnings
                print(('Insert wineitems from legacy successful, '
                       f'{rows_affected} rows affected, {warnings} warnings ({exectime:.3f} secs)'))
                if show_warnings and warnings > 0:
                    CHW_SQL.print_cursor_warnings(insert_wineitems_from_legacy_cursor)

            self._connection.commit()
        except mariadb.Error as e:
            print(type(e))
            print(e.args)
            print(e)
            print(sql)
            # We don't need the stacktrace output, so don't reraise the exception
            # raise e from None

    def insert_westerninventory_from_legacy(self, params):
        """
        Create western inventory records in the WesternInventory table from the
        LegacyWineMaster records with matching WineItem records

        :param params: dictionary of keyword parameters used to format the sql string
                       used. Only needs suffix of the current LegacyWineMaster table. e.g. '_0824'
        :type params: {'suffix': str}
        """
        # TODO: set this flag from a parameter
        show_warnings = True

        sql = CHW_SQL.get_insert_westerninventory_from_legacy_sql(params)

        try:
            with (self._connection.cursor() as insert_westerninventory_from_legacy_cursor):
                t = time.process_time()
                insert_westerninventory_from_legacy_cursor.execute(sql)
                exectime = time.process_time() - t

                rows_affected = insert_westerninventory_from_legacy_cursor.rowcount
                warnings = insert_westerninventory_from_legacy_cursor.warnings
                print(('Insert western inventory from legacy successful, '
                       f'{rows_affected} rows affected, {warnings} warnings ({exectime:.3f} secs)'))
                if show_warnings and warnings > 0:
                    CHW_SQL.print_cursor_warnings(insert_westerninventory_from_legacy_cursor)

            self._connection.commit()
        except mariadb.Error as e:
            print(type(e))
            print(e.args)
            print(e)
            print(sql)
            # We don't need the stacktrace output, so don't reraise the exception
            # raise e from None

    def insert_winepurchases_from_legacy(self, params):
        """
        Create wine purchase records in the WinePurchases table from the
        LegacyWineMaster records with matching WineItem records

        :param params: dictionary of keyword parameters used to format the sql string
                       used. Only needs suffix of the current LegacyWineMaster table. e.g. '_0824'
        :type params: {'suffix': str}
        """
        # TODO: set this flag from a parameter
        show_warnings = True

        sql = CHW_SQL.get_insert_winepurchases_from_legacy_sql(params)

        try:
            with (self._connection.cursor() as insert_winepurchases_from_legacy_cursor):
                t = time.process_time()
                insert_winepurchases_from_legacy_cursor.execute(sql)
                exectime = time.process_time() - t

                rows_affected = insert_winepurchases_from_legacy_cursor.rowcount
                warnings = insert_winepurchases_from_legacy_cursor.warnings
                print(('Insert wine purchases from legacy successful, '
                       f'{rows_affected} rows affected, {warnings} warnings ({exectime:.3f} secs)'))
                if show_warnings and warnings > 0:
                    CHW_SQL.print_cursor_warnings(insert_winepurchases_from_legacy_cursor)

            self._connection.commit()
        except mariadb.Error as e:
            print(type(e))
            print(e.args)
            print(e)
            print(sql)
            # We don't need the stacktrace output, so don't reraise the exception
            # raise e from None

    def insert_winepricing_from_legacy(self, params):
        """
        Create wine pricing records in the WinePricing table from the
        LegacyWineMaster records with matching WineItem records

        :param params: dictionary of keyword parameters used to format the sql string
                       used. Only needs suffix of the current LegacyWineMaster table. e.g. '_0824'
        :type params: {'suffix': str}
        """
        # TODO: set this flag from a parameter
        show_warnings = True

        sql = CHW_SQL.get_insert_winepricing_from_legacy_sql(params)

        try:
            with (self._connection.cursor() as insert_winepricing_from_legacy_cursor):
                t = time.process_time()
                insert_winepricing_from_legacy_cursor.execute(sql)
                exectime = time.process_time() - t

                rows_affected = insert_winepricing_from_legacy_cursor.rowcount
                warnings = insert_winepricing_from_legacy_cursor.warnings
                print(('Insert wine pricing from legacy successful, '
                       f'{rows_affected} rows affected, {warnings} warnings ({exectime:.3f} secs)'))
                if show_warnings and warnings > 0:
                    CHW_SQL.print_cursor_warnings(insert_winepricing_from_legacy_cursor)

            self._connection.commit()
        except mariadb.Error as e:
            print(type(e))
            print(e.args)
            print(e)
            print(sql)
            # We don't need the stacktrace output, so don't reraise the exception
            # raise e from None

    def insert_winewholesalepricing_from_legacy(self, params):
        """
        Create wine pricing records in the WineWholesalePricing and
        WineWholesaleCaseBreaks tables from the LegacyWineMaster records
        with matching WineItem records

        :param params: dictionary of keyword parameters used to format the sql string
                       used. Only needs suffix of the current LegacyWineMaster table. e.g. '_0824'
        :type params: {'suffix': str}
        """
        # Alias column indices enum for clarity
        Col = CHW_SQL.Col_legacy_winewholesalepricing

        select_winewholesalepricing_sql = CHW_SQL.get_select_winewholesalepricing_from_legacy_sql(params)

        try:
            with (self._connection.cursor() as select_winewholesalepricing_from_legacy_cursor):
                t = time.process_time()

                select_winewholesalepricing_from_legacy_cursor.execute(select_winewholesalepricing_sql)

                pricing_rows_added = 0
                casebreak_rows_added = 0

                for wholesalepricing_row in select_winewholesalepricing_from_legacy_cursor:
                    wineItemId = wholesalepricing_row[Col.WineItemId]
                    wholesale_price = wholesalepricing_row[Col.NY_Wholesale]

                    if wholesale_price is not None:
                        self._insert_wholesale_pricing(wineItemId, 'NY', wholesale_price)
                        pricing_rows_added += 1

                        casebreak_rows_added += \
                            self._insertwholesale_casebreak(wineItemId, 'NY',
                                                            wholesalepricing_row[Col.NY_MultiCaseQty1],
                                                            wholesalepricing_row[Col.NY_MultiCasePrice1])
                        casebreak_rows_added += \
                            self._insertwholesale_casebreak(wineItemId, 'NY',
                                                            wholesalepricing_row[Col.NY_MultiCaseQty2],
                                                            wholesalepricing_row[Col.NY_MultiCasePrice2])
                        casebreak_rows_added += \
                            self._insertwholesale_casebreak(wineItemId, 'NY',
                                                            wholesalepricing_row[Col.NY_MultiCaseQty3],
                                                            wholesalepricing_row[Col.NY_MultiCasePrice3])

                    wholesale_price = wholesalepricing_row[Col.NJ_Wholesale]
                    if wholesale_price is not None:
                        self._insert_wholesale_pricing(wineItemId, 'NJ', wholesale_price)
                        pricing_rows_added += 1

                        casebreak_rows_added += \
                            self._insertwholesale_casebreak(wineItemId, 'NJ',
                                                            wholesalepricing_row[Col.NJ_MultiCaseQty1],
                                                            wholesalepricing_row[Col.NJ_MultiCasePrice1])
                        casebreak_rows_added += \
                            self._insertwholesale_casebreak(wineItemId, 'NJ',
                                                            wholesalepricing_row[Col.NJ_MultiCaseQty2],
                                                            wholesalepricing_row[Col.NJ_MultiCasePrice2])
                        casebreak_rows_added += \
                            self._insertwholesale_casebreak(wineItemId, 'JY',
                                                            wholesalepricing_row[Col.NJ_MultiCaseQty3],
                                                            wholesalepricing_row[Col.NJ_MultiCasePrice3])

                exectime = time.process_time() - t

            print((f'Insert wholesale pricing from legacy successful ({exectime:.3f} secs)\n'
                   f'\t - {pricing_rows_added} pricing rows added, '
                   f'{casebreak_rows_added} case break rows added'))

            self._connection.commit()
        except mariadb.Error as e:
            print(type(e))
            print(e.args)
            print(e)
            print(select_winewholesalepricing_sql)
            # We don't need the stacktrace output, so don't reraise the exception
            # raise e from None

    def _insert_wholesale_pricing(self, wineItemId, stateAbbrev, price):
        """
        Insert a record w/ the given values into the WineWholesalePricing table
        """
        self._insert_winewholesalepricing_cursor.execute(CHW_SQL.insert_winewholesalepricing_sql,
                                                         (wineItemId, stateAbbrev, price))

    def _insertwholesale_casebreak(self, wineItemId, stateAbbrev, qty, price):
        """
        Insert a record w/ the given values into the WineWholesaleCaseBreaks table
        if the qty given is not None

        :return: the number of rows inserted (0 if qty is None, 1 otherwise)
        :rtype: int
        """
        if qty is None:
            return 0

        self._insert_winewholesalecasebreaks_cursor.execute(CHW_SQL.insert_winewholesalecasebreaks_sql,
                                                            (wineItemId, stateAbbrev, qty, price))
        return 1
