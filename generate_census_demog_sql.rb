# frozen_string_literal: true

require 'csv'
require 'pry'

census_demog_csvs = ['census_demog_2019_lt25.csv', 'census_demog_2019_gt25.csv']

class CensusDemogGenerator
  STRING_COLUMNS = ['BLOCK', 'CENSUS_DATA_SRC', 'GEOCODE',
                    'CHORDS_GEOLEVEL', 'STATE', 'COUNTY',
                    'TRACT', 'BLOCKGP', 'ZIP']

  VALID_COLUMNS = %w[CENSUS_YEAR GEOCODE BLOCK CENSUS_DATA_SRC CHORDS_GEOLEVEL STATE COUNTY
                     TRACT BLOCKGP HOUSES_N RA_NHS_WH RA_NHS_BL RA_NHS_AM RA_NHS_AS RA_NHS_HA
                     RA_NHS_OT RA_NHS_ML RA_HIS_WH RA_HIS_BL RA_HIS_AM RA_HIS_AS RA_HIS_HA
                     RA_HIS_OT RA_HIS_ML HOUSES_OCCUPIED HOUSES_OWN HOUSES_RENT
                     HOUSES_UNOCC_FORRENT HOUSES_UNOCC_FORSALE HOUSES_UNOCC_RENTSOLD
                     HOUSES_UNOCC_SEASONAL HOUSES_UNOCC_MIGRANT HOUSES_UNOCC_OTHER EDUCATION1
                     EDUCATION2 EDUCATION3 EDUCATION4 EDUCATION5 EDUCATION6 EDUCATION7 EDUCATION8
                     MEDFAMINCOME FAMINCOME1 FAMINCOME2 FAMINCOME3 FAMINCOME4 FAMINCOME5
                     FAMINCOME6 FAMINCOME7 FAMINCOME8 FAMINCOME9 FAMINCOME10 FAMINCOME11
                     FAMINCOME12 FAMINCOME13 FAMINCOME14 FAMINCOME15 FAMINCOME16 MEDHOUSINCOME
                     HOUSINCOME1 HOUSINCOME2 HOUSINCOME3 HOUSINCOME4 HOUSINCOME5 HOUSINCOME6
                     HOUSINCOME7 HOUSINCOME8 HOUSINCOME9 HOUSINCOME10 HOUSINCOME11 HOUSINCOME12
                     HOUSINCOME13 HOUSINCOME14 HOUSINCOME15 HOUSINCOME16 POV_LT_50 POV_50_74
                     POV_75_99 POV_100_124 POV_125_149 POV_150_174 POV_175_184 POV_185_199
                     POV_GT_200 ENGLISH_SPEAKER SPANISH_SPEAKER BORNINUS MOVEDINLAST12MON MARRIED
                     DIVORCED DISABILITY UNEMPLOYMENT UNEMPLOYMENT_MALE INS_MEDICARE INS_MEDICAID
                     HH_NOCAR HH_PUBLIC_ASSISTANCE HMOWNER_COSTS_MORT HMOWNER_COSTS_NO_MORT
                     HOMES_MEDVALUE PCT_CROWDING FEMALE_HEAD_OF_HH MGR_FEMALE MGR_MALE RESIDENTS_65
                     SAME_RESIDENCE FAMPOVERTY HOUSPOVERTY ZIP].freeze

  attr_reader :batch_size, :output_filename

  def initialize(input_filename:, batch_size: 10, output_filename: nil)
    @input_filename = input_filename
    @output_filename = output_filename || "#{File.basename(input_filename, '.*')}.sql"
    @batch_size = batch_size
    @queue = Queue.new
  end

  def generate_insert_string(row)
    fields = row.to_h
    insert_string = VALID_COLUMNS.inject('(') do |build_string, header|
      field = if fields[header].nil?
                'NULL'
              elsif STRING_COLUMNS.include?(header)
                "'#{fields[header]}'"
              else
                fields[header]
              end
      "#{build_string}#{field},"
    end
    insert_string[-1] = ')'
    insert_string
  end

  def flush_queue
    insert_values = insert_statement
    until @queue.empty?
      insert_values = insert_values + generate_insert_string(@queue.pop) + (@queue.empty? ? ";\n" : ",\n")
    end
    insert_values
  end

  def enqueue_row(row)
    write_to_file flush_queue if @queue.length == batch_size
    @queue.enq(row)
  end

  def insert_statement
    "INSERT INTO vdw.census_demog (#{VALID_COLUMNS.join(',')}) VALUES \n".gsub(/STATE/, '"STATE"')
  end

  def write_to_file(content)
    File.open(output_filename, 'a') { |file| file.write(content) }
  end

  def process
    CSV.foreach(@input_filename, headers: true, encoding: 'bom|utf-8') do |row|
      enqueue_row(row)
    end
    write_to_file flush_queue unless @queue.empty?
  end

  def headers
    return @headers if @headers

    csv_headers ||= CSV.foreach(@input_filename).first
    csv_headers[0].gsub!("\xEF\xBB\xBF", '')
    @headers = csv_headers
  end
end

CensusDemogGenerator.new(input_filename: census_demog_csvs[0]).process
