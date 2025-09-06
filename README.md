Cynthia Hurley Fine Wines Source Repository
===========================================

[Cynthia Hurley Fine Wines][CHFW Web] (AKA CHFW or CHW) is a wine importer company owned
by Angelo Manioudakis a friend of Gillian Lippert.

I (Mike Lippert) have been working w/ Gilli designing a database schema to help streamline
the CFW operation.

This repository contains files related to that.

As CFW currently has some data in [FileMaker][Filemaker Web] databases, our initial effort
is on using that tool.

However, it seems fairly proprietary which has prompted me to try other tools.

I'm curious about using [LibreOffice Base][Base Guide], connected to an open relational
database such as [Firebird][Firebird docs], [MySQL][mysql docs] or [MariaDB][mariadb docs].

In addition I'm trying [SQL Power Architect][SQL Power Architect download] for designing the database
schema which I hope will help make it easy to implement that schema on various SQL databases.

## Database Object Naming Conventions Used Here

These are what we have currently chosen to do, but it is early and the [SQLShack article][SQLShack conventions]
may change these decisions. The StackOverflow [question on singular vs plural][SO singular vs plural]
got a lot of interesting discussion, maybel leading me to keep much of the conventions
we've already started.

- Tables: Plural nouns, Pascal Case e.g. ClientCreditCards
    - prefix small lookup tables w/ "Lookup", e.g. LookupCCIssuers
    - Name association tables by concatinating the 2 associated table names w/ an underscore `_`
      An exception might be to add a modifier to an association table name to a filtered
      use case (think Addresses to ShippingAddresses).
- Columns: Pascal Case, except for type prefixes (such as pk for primary keys)
    - Primary keys fields use a suffix of "Id" EXCEPT when the primary key is composed of multiple fields
    - Foreign keys use the same field name(s) as in the table they are a primary key for
    - Use `N` for the name of a primary key additional column containing an integer to make
      a foreign key into a unique primary key for an association table.  
      Think of having 0-n where n is typically a small number (but less than 100) of some
      characteristic, say a Contact's email address(es) or phone number(s). The primary
      key in the email table would be the Contact's foreign key column PLUS the `N`
      column.  
      A column name of `index` is not really the correct meaning for this, AND it's
      sometimes a SQL keyword. The problem w/ using `slot` or `entry` as the name of this
      field is it lends itself to changing the value in the "slot" rather than addind a
      new "slot" which could be problematic if the row has a relationship to another
      table.

## Development

### Utilities in the Repository

#### Running various databases in containers

There is a `docker-compose.yml` file which has services set up for running 3 databases

1. mariadb
2. mysql
3. mongodb

There is a `Makefile` with targets for starting and stopping those services. The Makefile
currently is defined to use `podman` and `podman-compose` to do that. The `up` and `down`
targets will start and stop the `chw-mariadb` service (container).

There is a bash script `bin/chwdb-cli.sh` which will run the mariadb cli in the running
chw-mariadb service container.

## Resources

- Database naming conventions article from [SQLShack][SQLShack conventions] proposes singular
  table names and snake case
- Descriptions of casing styles [(Camel, Pascal, Snake, Kebab)][Case naming styles]

[CHFW Web]: <https://cynthiahurley.com/> "Cynthia Hurley Fine Wines website"
[Filemaker Web]: <https://www.claris.com/filemaker/> "Claris Filemaker website"
[Base Guide]: <https://www.libreofficehelp.com/libreoffice-base/> "LibreOffice Base Help Beginner's Guide"
[Firebird docs]: <https://firebirdsql.org/en/firebird-rdbms/> "Firebird documentation"
[mysql docs]: <https://dev.mysql.com/doc/mysqld-version-reference/en/> "mysql documentation"
[mariadb docs]: <https://mariadb.org/documentation/> "MariaDB documentation"
[SQL Power Architect download]: <https://bestofbi.com/architect-download/> "SQL Power Architect downloads"
[SQLShack conventions]: <https://www.sqlshack.com/learn-sql-naming-conventions/> "SQL DB naming conventions"
[Case naming styles]: <https://thelinuxcode.com/programming-naming-conventions-camel-snake-kebab-and-pascal-case-explained/> "Case styles explained"
[SO singular vs plural]: <https://stackoverflow.com/questions/338156/table-naming-dilemma-singular-vs-plural-names> "StackOverflow database singular vs plural discussion"
