#!/usr/bin/env python
"""
################################################################################
  main.py
################################################################################

This is the main module to provide context for all the local application pkgs

=============== ================================================================
Created on     October 23, 2025
--------------- ----------------------------------------------------------------
author(s)       Michael Jay Lippert
--------------- ----------------------------------------------------------------
Copyright       (c) 2025-present Michael Jay Lippert
                MIT License (see https://opensource.org/licenses/MIT)
=============== ================================================================
"""

# Standard library imports

# Third party imports
import click

# Local application imports
from chwdata.retail_orders import do_create_customers_from_legacy


@click.command()
@click.option('--user', '-u', type=click.Choice(['Gillian', 'Mike']), default='Gillian', required=False, help='User name for CreatedBy and LastModifiedBy fields')
def import_legacy_customers(user):
    """
    Create email customers from the legacy customer orders table

    \b
    options:
    user    - user name for CreatedBy and LastModifiedBy fields. Default: Gillian
    """
    do_create_customers_from_legacy(user=user)


@click.group()
def cli():
    """Run CHW database actions

    Connects to the mariadb at localhost:3306
    """
    # pylint: disable=unnecessary-pass
    pass


cli.add_command(import_legacy_customers)


if __name__ == '__main__':
    cli()
