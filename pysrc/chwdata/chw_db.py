"""
################################################################################
  chwdata.chw_db.py
################################################################################

This module provides the base class for connecting to the mariadb chw database.

Python naming convention reminder note: single underscore prefix class names are
for "private" internal use and should not be considered part of the public API.

=============== ================================================================
Created on      November 19, 2025
--------------- ----------------------------------------------------------------
author(s)       Michael Jay Lippert
--------------- ----------------------------------------------------------------
Copyright       (c) 2025-present Michael Jay Lippert
                MIT License (see https://opensource.org/licenses/MIT)
=============== ================================================================
"""

# Standard library imports
import sys

# Third party imports
import mariadb

# Local application imports


default_domain = '127.0.0.1'
default_port = 3306
default_db_name = 'chw'
default_db_user = 'chwuser'
default_db_password = 'cynthiahurley'


class CHW_DB:
    """
    CHW Database base class will connect to the Mariadb database when initialized
    and close the connection when deleted.
    The connection is in the instance variable `_connection`, and the connection
    configuration parameters used to create that connection are in `_db_config`.
    These variables are intended for use by derived classes.
    """

    def __init__(self, *,
                 domain=None,
                 port=None,
                 db_name=None,
                 db_user=None,
                 db_password=None):
        """
        Initialize the CHW_DB class, setting initial values for all instance variables
        """
        self._db_config = {'host':     domain if domain is not None else default_domain,
                           'port':     port if port is not None else default_port,
                           'user':     db_user if db_user is not None else default_db_user,
                           'password': db_password if db_password is not None else default_db_password,
                           'database': db_name if db_name is not None else default_db_name
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


def _test():
    pass


if __name__ == '__main__':
    _test()
