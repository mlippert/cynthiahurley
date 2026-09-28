"""
################################################################################
  chw_sql.py
################################################################################

This module provides SQL statements for working with the CHW database tables.

Python naming convention reminder note: single underscore prefix class names are
for "private" internal use and should not be considered part of the public API.

=============== ================================================================
Created on      December 6, 2025
--------------- ----------------------------------------------------------------
author(s)       Michael Jay Lippert
--------------- ----------------------------------------------------------------
Copyright       (c) 2025-present Michael Jay Lippert
                MIT License (see https://opensource.org/licenses/MIT)
=============== ================================================================
"""

# Standard library imports

# Third party imports

# Local application imports
from .chw_sql_email import CHW_SQL_Email
from .chw_sql_wine import CHW_SQL_Wine


class CHW_SQL(CHW_SQL_Email, CHW_SQL_Wine):
    """
    CHW_SQL provides the sql statements used by to operate on the mariadb chw
    database tables and other entities.

    As sql statements can be long and span many lines encapsulating them in
    this class helps organize them and allows the code where they are used to
    be more easily read.
    """

    @staticmethod
    def print_cursor_warnings(cursor):
        """
        Print the warnings from the last execution of the given cursor
        """
        for severity, code, msg in cursor.connection.show_warnings():
            print(severity, code, msg)
