# pcor-cdm
This project reads in the [PCORnet Common Data Model v4.1 Parseable Spreadsheet Format](https://github.com/CDMFORUM/CDM-GUIDANCE/raw/master/Files%20for%20CDM%20page/2018-12-05-PCORnet-Common-Data-Model-v4dot1-parseable.xlsx) and will create database tables to represent the CDM.

This application is written in Ruby and it uses the [Sequel](http://sequel.jeremyevans.net/index.html) library to generate the appropriate DDL.

This script currently creates the tables, sets not null constraints and primary keys. It does not yet handle creating the foreign key relationships.

*Note* The CSV files were created using Excel to open the parseable file and then perform an export to CSV. Excel will put a Byte Order Marker (BOM) in the file, which throws off the standard ruby CSV parsing library. The CSV files were re-encoded to UTF-8 using Visual Studio Code.