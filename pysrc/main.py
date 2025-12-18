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
from chwdata.wines import (do_load_legacy_wine_master_from_csv,
                           do_create_producers_from_legacy,
                           do_setup_lookup_table_records,
                           do_create_wines_from_legacy)


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
def setup_wine_lookup_tables():
    """
    Insert the standard records into empty wine lookup tables

    \b
    - LookupWineColors
    - LookupWineTypes
    - LookupCaseUnits
    - LookupWineCountries
    - LookupWineRegions
    - LookupWineSubregions
    - LookupWineAppellations
    """
    do_setup_lookup_table_records()


@click.command()
def write_top_customer_order_report():
    """
    Write out the top customer order item report (to stdout)
    """
    do_write_top_customer_order_report()


@click.command()
def import_legacy_producers():
    """
    Create producers from the legacy wine master table
    """
    do_create_producers_from_legacy()


@click.command()
def create_wines_from_legacy():
    """
    Create records in the Wines table from the legacy wine master table

    The producers must have already been imported, and the wine lookup
    tables initialized.
    """
    do_create_wines_from_legacy()


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
cli.add_command(setup_wine_lookup_tables)
cli.add_command(create_wines_from_legacy)


if __name__ == '__main__':
    cli()
