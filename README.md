# CODI Schema
This project reads in the [PCORnet Common Data Model v4.1 Parseable Spreadsheet Format](https://github.com/CDMFORUM/CDM-GUIDANCE/raw/master/Files%20for%20CDM%20page/2018-12-05-PCORnet-Common-Data-Model-v4dot1-parseable.xlsx) and will create database tables to represent the CDM.

This project has been updated to support [PCORnet Common Data Model v6.0 Parseable Spreadsheet Format](https://pcornet.org/wp-content/uploads/2021/05/2021_04_12_PCORnet_Common_Data_Model_v6dot0_parseable.xlsx)

This application is written in Ruby and it uses the [Sequel](http://sequel.jeremyevans.net/index.html) library to generate the appropriate DDL.

This script currently creates the tables, sets not null constraints and primary keys. It does not yet handle creating the foreign key relationships.

**Note** The CSV files were created using Excel to open the parseable file and then perform an export to CSV. Excel will put a Byte Order Marker (BOM) in the file, which throws off the standard ruby CSV parsing library. The CSV files were re-encoded to UTF-8 using Visual Studio Code.

## Prerequisites

This was built using ruby 2.6.2. It used inline [Bundler](https://bundler.io/) to manage dependencies. Assuming you have ruby installed, you can:

    gem install bundler

## Running

The connection information exists in the ruby file: `build_db.rb`:
```
DB = Sequel.connect(adapter: 'postgres', :host => 'localhost',
  :database => 'codi',
  :user => 'codi',
  :password => 'codi')
```
Change these values as appropriate to point to your database instance. The following adapters should be supported: `postgres`, `mysql`, `oracle`, `mssql`


To create the schema, just run the script:

    ruby build_db.rb

It assumes that the database has been created and is empty. It will create all of the columns after that.


## Notice

Copyright 2022 The MITRE Corporation.

Approved for Public Release; Distribution Unlimited. Case Number 19-2008