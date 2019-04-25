require 'csv'
require 'logger'

require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'
  gem 'sequel'
  gem 'pg'
end

DB = Sequel.connect(adapter: 'postgres', :host => 'localhost',
  :database => 'codi',
  :user => 'codi',
  :password => 'codi')

DB.loggers << Logger.new($stdout)

DB.extension :identifier_mangling
DB.quote_identifiers = false

TYPE_MAPPING = {'Text' => 'varchar', 'Date' => 'date', 'Number' => 'numeric'}

def data_type(cdm_type_description)
    md = /RDBMS (Text|Date|Number)(\((\d+|x)\))?/.match(cdm_type_description)
    type_description = TYPE_MAPPING[md[1]]
    if md[3] && md[3] != 'x'
        type_description += "(#{md[3]})"
    end
    type_description
end

DB.create_schema :CDM

fields = CSV.read('fields.csv', headers: true)
relational = CSV.read('relational.csv', headers: true)
constraints = CSV.read('constraints.csv', headers: true)
by_table = fields.group_by {|r| r['TABLE_NAME']}
by_table.each_pair do |table_name, rows|
  DB.create_table(Sequel[:CDM][table_name.to_sym]) do
    rows.each do |row|
      row_attributes = {}
      field_name = row['FIELD_NAME']
      row_attributes[:type] = data_type(row['RDBMS_DATA_TYPE'])
      if relational.find {|r| r['TABLE_NAME'] == table_name && r['RELATION'] == 'PK' &&
            r['RELATIONAL_INTEGRITY_DETAILS'] == field_name}
        row_attributes[:primary_key] = true
      end
      if constraints.find {|r| r['TABLE_NAME'] == table_name && r['CONSTRAINT'] == 'required, not null' &&
             r['FIELD_NAME'] == field_name}
        row_attributes[:null] = false
      end
      column field_name.to_sym, row_attributes[:type], row_attributes
    end

    ck = relational.find {|r| r['TABLE_NAME'] == table_name && r['RELATION'] == 'Composite Key'}
    if ck
      columns = ck['RELATIONAL_INTEGRITY_DETAILS']
      primary_key columns.split(" + ").map{|n| n.to_sym}
    end
  end
end

ancillary_tables_sql = File.read('ancillary_codi_tables.sql')
DB << ancillary_tables_sql

