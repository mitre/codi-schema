# CODI Schema
This project reads in the [PCORnet Common Data Model v6.0 Parseable Spreadsheet Format](https://pcornet.org/wp-content/uploads/2021/11/2021_11_29_PCORnet_Common_Data_Model_v6dot0_parseable.xlsx) and will create database tables to represent the CDM.

This application is written in Ruby and it uses the [Sequel](http://sequel.jeremyevans.net/index.html) library to generate the appropriate DDL.

This script currently creates the tables, sets not null constraints and primary keys. It does not yet handle creating the foreign key relationships.

**Note** The CSV files were created using Excel to open the parseable file and then perform an export to CSV. Excel will put a Byte Order Marker (BOM) in the file, which throws off the standard ruby CSV parsing library. The CSV files were re-encoded to UTF-8 using Visual Studio Code.

## Prerequisites

This was built using ruby 2.6.2. It used inline [Bundler](https://bundler.io/) to manage dependencies. Assuming you have ruby installed, you can:

    gem install bundler

## Running

The connection information exists in the ruby file: `build_db.rb`:
```ruby
# build_db.rb

DB = Sequel.connect(adapter: 'postgres', :host => 'localhost',
  :database => 'codi',
  :user => 'codi',
  :password => 'codi')
```
Change these values as appropriate to point to your database instance. The following adapters should be supported: `postgres`, `mysql`, `oracle`, `mssql`

### Optional Generate Census Demographic Data

Users may provide their own SQL files to generate census demographic data to load into `vdw.census_demog` or use the `generate_census_demog_sql.rb` script
to generate a SQL insertion file from a CSV with headers matching the columns in the `vdw.census_demog` table.

Users can point the script to the csv files from which to generate the loading scripts by editing the `census_demog_csvs` variable within `generate_census_demog_sql.rb`
to match the filenames of the source CSVs.

```ruby
# generate_census_demog_sql.rb

census_demog_csvs = ['census_demog_2019_lt25.csv', 'census_demog_2019_gt25.csv']
```

`generate_census_demog_sql.rb` will generate files with the same name as the source CSVs, but with the `.sql` file extension.

SQL files generated from `generate_census_demog_sql.rb` or from other sources can be loaded into the database by adding their filenames to the
`ancilliary_tables_sql_file` array in `build_db.rb`.

```ruby
# build_db.rb

ancillary_tables_sql_files = [
  'ancillary_codi_tables.sql',
  'schema_omop.sql',
  'schema_vdw.sql',
  'census_demog_2019_lt25.csv',
  'census_demog_2019_gt25.csv'
]
```
### Creating the Schema

To create the schema, just run the script:

    ruby build_db.rb

It assumes that the database has been created and is empty. It will create all of the columns after that.

### Postgres

The Postgres user must have `CONNECT` and `CREATE` privileges in order for this script to run successfully. A user can be granted these scopes with:

```sql
GRANT CONNECT ON DATABASE codi_db TO codi;
GRANT CREATE ON DATABASE codi_db TO codi;
```

[Postgres Privileges](https://www.postgresql.org/docs/current/ddl-priv.html)

## Notice

Copyright 2022 The MITRE Corporation.

Approved for Public Release; Distribution Unlimited. Case Number 19-2008
