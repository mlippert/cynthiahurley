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
from chwdata.retail_orders import (do_load_legacy_email_orders_from_csv,
                                   do_write_top_customer_order_report,
                                   do_create_customers_from_legacy)
from chwdata.wines import do_load_legacy_wine_master_from_csv, do_create_producers_from_legacy


@click.command()
@click.option('--user', '-u', type=click.Choice(['Gillian', 'Mike']), default='Gillian',
              required=False, help='User name for CreatedBy and LastModifiedBy fields')
def import_legacy_customers(user):
    """
    Create email customers from the legacy customer orders table

    \b
    options:
    user    - user name for CreatedBy and LastModifiedBy fields. Default: Gillian
    """
    do_create_customers_from_legacy(user=user)


@click.command()
def load_legacy_email_orders_from_csv():
    """
    Load the LegacyEmailOrders table from the csv file in the data/infile dir

    \b
    Note that currently the datadir, csvfile and table suffix are hardcoded
    so if they have changed the supporting function must be updated.
    """
    do_load_legacy_email_orders_from_csv()


@click.command()
def load_legacy_wine_master_from_csv():
    """
    Load the LegacyWineMaster table from the csv file in the data/infile dir

    \b
    Note that currently the datadir, csvfile and table suffix are hardcoded
    so if they have changed the supporting function must be updated.
    """
    do_load_legacy_wine_master_from_csv()


@click.command()
def write_top_customer_order_report():
    """
    Write out the top customer order item report (to stdout)
    """
    do_write_top_customer_order_report()


@click.command()
@click.option('--user', '-u', type=click.Choice(['Legacy', 'Gillian', 'Mike']), default='Legacy',
              required=False, help='User name for CreatedBy and LastModifiedBy fields')
def import_legacy_producers(user):
    """
    Create producers from the legacy wine master table

    \b
    options:
    user    - user name for CreatedBy and LastModifiedBy fields. Default: Legacy
    """
    do_create_producers_from_legacy(user=user)


@click.group()
def cli():
    """Run CHW database actions

    Connects to the mariadb at localhost:3306
    """
    # pylint: disable=unnecessary-pass
    pass


cli.add_command(import_legacy_customers)
cli.add_command(write_top_customer_order_report)
cli.add_command(import_legacy_producers)
cli.add_command(load_legacy_email_orders_from_csv)
cli.add_command(load_legacy_wine_master_from_csv)


if __name__ == '__main__':
    cli()
