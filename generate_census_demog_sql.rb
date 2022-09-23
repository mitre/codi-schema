# frozen_string_literal: true

require 'csv'

census_demog_csvs = ['census_demog_2019_lt25.csv', 'census_demog_2019_gt25.csv']

class CensusDemogGenerator
  VALID_COLUMNS = {
    'CENSUS_YEAR' => { type: 'int', nullable: false },
    'GEOCODE' => { type: 'varchar', length: 15, nullable: false },
    'BLOCK' => { type: 'varchar', length: 3, nullable: true },
    'CENSUS_DATA_SRC' => { type: 'varchar', length: 26, nullable: true },
    'CHORDS_GEOLEVEL' => { type: 'varchar', length: 10, nullable: true },
    'STATE' => { type: 'varchar', length: 2, nullable: true },
    'COUNTY' => { type: 'varchar', length: 3, nullable: true },
    'TRACT' => { type: 'varchar', length: 6, nullable: true },
    'BLOCKGP' => { type: 'varchar', length: 1, nullable: true },
    'HOUSES_N' => { type: 'int', nullable: true },
    'RA_NHS_WH' => { type: 'decimal', precision: 6, scale: 4, nullable: true },
    'RA_NHS_BL' => { type: 'decimal', precision: 6, scale: 4, nullable: true },
    'RA_NHS_AM' => { type: 'decimal', precision: 6, scale: 4, nullable: true },
    'RA_NHS_AS' => { type: 'decimal', precision: 6, scale: 4, nullable: true },
    'RA_NHS_HA' => { type: 'decimal', precision: 6, scale: 4, nullable: true },
    'RA_NHS_OT' => { type: 'decimal', precision: 6, scale: 4, nullable: true },
    'RA_NHS_ML' => { type: 'decimal', precision: 6, scale: 4, nullable: true },
    'RA_HIS_WH' => { type: 'decimal', precision: 6, scale: 4, nullable: true },
    'RA_HIS_BL' => { type: 'decimal', precision: 6, scale: 4, nullable: true },
    'RA_HIS_AM' => { type: 'decimal', precision: 6, scale: 4, nullable: true },
    'RA_HIS_AS' => { type: 'decimal', precision: 6, scale: 4, nullable: true },
    'RA_HIS_HA' => { type: 'decimal', precision: 6, scale: 4, nullable: true },
    'RA_HIS_OT' => { type: 'decimal', precision: 6, scale: 4, nullable: true },
    'RA_HIS_ML' => { type: 'decimal', precision: 6, scale: 4, nullable: true },
    'HOUSES_OCCUPIED' => { type: 'decimal', precision: 6, scale: 4, nullable: true },
    'HOUSES_OWN' => { type: 'decimal', precision: 6, scale: 4, nullable: true },
    'HOUSES_RENT' => { type: 'decimal', precision: 6, scale: 4, nullable: true },
    'HOUSES_UNOCC_FORRENT' => { type: 'decimal', precision: 6, scale: 4, nullable: true },
    'HOUSES_UNOCC_FORSALE' => { type: 'decimal', precision: 6, scale: 4, nullable: true },
    'HOUSES_UNOCC_RENTSOLD' => { type: 'decimal', precision: 6, scale: 4, nullable: true },
    'HOUSES_UNOCC_SEASONAL' => { type: 'decimal', precision: 6, scale: 4, nullable: true },
    'HOUSES_UNOCC_MIGRANT' => { type: 'decimal', precision: 6, scale: 4, nullable: true },
    'HOUSES_UNOCC_OTHER' => { type: 'decimal', precision: 6, scale: 4, nullable: true },
    'EDUCATION1' => { type: 'decimal', precision: 6, scale: 4, nullable: true },
    'EDUCATION2' => { type: 'decimal', precision: 6, scale: 4, nullable: true },
    'EDUCATION3' => { type: 'decimal', precision: 6, scale: 4, nullable: true },
    'EDUCATION4' => { type: 'decimal', precision: 6, scale: 4, nullable: true },
    'EDUCATION5' => { type: 'decimal', precision: 6, scale: 4, nullable: true },
    'EDUCATION6' => { type: 'decimal', precision: 6, scale: 4, nullable: true },
    'EDUCATION7' => { type: 'decimal', precision: 6, scale: 4, nullable: true },
    'EDUCATION8' => { type: 'decimal', precision: 6, scale: 4, nullable: true },
    'MEDFAMINCOME' => { type: 'int', nullable: true },
    'FAMINCOME1' => { type: 'decimal', precision: 6, scale: 4, nullable: true },
    'FAMINCOME2' => { type: 'decimal', precision: 6, scale: 4, nullable: true },
    'FAMINCOME3' => { type: 'decimal', precision: 6, scale: 4, nullable: true },
    'FAMINCOME4' => { type: 'decimal', precision: 6, scale: 4, nullable: true },
    'FAMINCOME5' => { type: 'decimal', precision: 6, scale: 4, nullable: true },
    'FAMINCOME6' => { type: 'decimal', precision: 6, scale: 4, nullable: true },
    'FAMINCOME7' => { type: 'decimal', precision: 6, scale: 4, nullable: true },
    'FAMINCOME8' => { type: 'decimal', precision: 6, scale: 4, nullable: true },
    'FAMINCOME9' => { type: 'decimal', precision: 6, scale: 4, nullable: true },
    'FAMINCOME10' => { type: 'decimal', precision: 6, scale: 4, nullable: true },
    'FAMINCOME11' => { type: 'decimal', precision: 6, scale: 4, nullable: true },
    'FAMINCOME12' => { type: 'decimal', precision: 6, scale: 4, nullable: true },
    'FAMINCOME13' => { type: 'decimal', precision: 6, scale: 4, nullable: true },
    'FAMINCOME14' => { type: 'decimal', precision: 6, scale: 4, nullable: true },
    'FAMINCOME15' => { type: 'decimal', precision: 6, scale: 4, nullable: true },
    'FAMINCOME16' => { type: 'decimal', precision: 6, scale: 4, nullable: true },
    'MEDHOUSINCOME' => { type: 'int', nullable: true },
    'HOUSINCOME1' => { type: 'decimal', precision: 6, scale: 4, nullable: true },
    'HOUSINCOME2' => { type: 'decimal', precision: 6, scale: 4, nullable: true },
    'HOUSINCOME3' => { type: 'decimal', precision: 6, scale: 4, nullable: true },
    'HOUSINCOME4' => { type: 'decimal', precision: 6, scale: 4, nullable: true },
    'HOUSINCOME5' => { type: 'decimal', precision: 6, scale: 4, nullable: true },
    'HOUSINCOME6' => { type: 'decimal', precision: 6, scale: 4, nullable: true },
    'HOUSINCOME7' => { type: 'decimal', precision: 6, scale: 4, nullable: true },
    'HOUSINCOME8' => { type: 'decimal', precision: 6, scale: 4, nullable: true },
    'HOUSINCOME9' => { type: 'decimal', precision: 6, scale: 4, nullable: true },
    'HOUSINCOME10' => { type: 'decimal', precision: 6, scale: 4, nullable: true },
    'HOUSINCOME11' => { type: 'decimal', precision: 6, scale: 4, nullable: true },
    'HOUSINCOME12' => { type: 'decimal', precision: 6, scale: 4, nullable: true },
    'HOUSINCOME13' => { type: 'decimal', precision: 6, scale: 4, nullable: true },
    'HOUSINCOME14' => { type: 'decimal', precision: 6, scale: 4, nullable: true },
    'HOUSINCOME15' => { type: 'decimal', precision: 6, scale: 4, nullable: true },
    'HOUSINCOME16' => { type: 'decimal', precision: 6, scale: 4, nullable: true },
    'POV_LT_50' => { type: 'decimal', precision: 6, scale: 4, nullable: true },
    'POV_50_74' => { type: 'decimal', precision: 6, scale: 4, nullable: true },
    'POV_75_99' => { type: 'decimal', precision: 6, scale: 4, nullable: true },
    'POV_100_124' => { type: 'decimal', precision: 6, scale: 4, nullable: true },
    'POV_125_149' => { type: 'decimal', precision: 6, scale: 4, nullable: true },
    'POV_150_174' => { type: 'decimal', precision: 6, scale: 4, nullable: true },
    'POV_175_184' => { type: 'decimal', precision: 6, scale: 4, nullable: true },
    'POV_185_199' => { type: 'decimal', precision: 6, scale: 4, nullable: true },
    'POV_GT_200' => { type: 'decimal', precision: 6, scale: 4, nullable: true },
    'ENGLISH_SPEAKER' => { type: 'decimal', precision: 6, scale: 4, nullable: true },
    'SPANISH_SPEAKER' => { type: 'decimal', precision: 6, scale: 4, nullable: true },
    'BORNINUS' => { type: 'decimal', precision: 6, scale: 4, nullable: true },
    'MOVEDINLAST12MON' => { type: 'decimal', precision: 6, scale: 4, nullable: true },
    'MARRIED' => { type: 'decimal', precision: 6, scale: 4, nullable: true },
    'DIVORCED' => { type: 'decimal', precision: 6, scale: 4, nullable: true },
    'DISABILITY' => { type: 'decimal', precision: 6, scale: 4, nullable: true },
    'UNEMPLOYMENT' => { type: 'decimal', precision: 6, scale: 4, nullable: true },
    'UNEMPLOYMENT_MALE' => { type: 'decimal', precision: 6, scale: 4, nullable: true },
    'INS_MEDICARE' => { type: 'decimal', precision: 6, scale: 4, nullable: true },
    'INS_MEDICAID' => { type: 'decimal', precision: 6, scale: 4, nullable: true },
    'HH_NOCAR' => { type: 'decimal', precision: 6, scale: 4, nullable: true },
    'HH_PUBLIC_ASSISTANCE' => { type: 'decimal', precision: 6, scale: 4, nullable: true },
    'HMOWNER_COSTS_MORT' => { type: 'decimal', precision: 6, scale: 4, nullable: true },
    'HMOWNER_COSTS_NO_MORT' => { type: 'decimal', precision: 6, scale: 4, nullable: true },
    'HOMES_MEDVALUE' => { type: 'int', nullable: true },
    'PCT_CROWDING' => { type: 'decimal', precision: 6, scale: 4, nullable: true },
    'FEMALE_HEAD_OF_HH' => { type: 'decimal', precision: 6, scale: 4, nullable: true },
    'MGR_FEMALE' => { type: 'decimal', precision: 6, scale: 4, nullable: true },
    'MGR_MALE' => { type: 'decimal', precision: 6, scale: 4, nullable: true },
    'RESIDENTS_65' => { type: 'decimal', precision: 6, scale: 4, nullable: true },
    'SAME_RESIDENCE' => { type: 'decimal', precision: 6, scale: 4, nullable: true },
    'FAMPOVERTY' => { type: 'decimal', precision: 6, scale: 4, nullable: true },
    'HOUSPOVERTY' => { type: 'decimal', precision: 6, scale: 4, nullable: true },
    'ZIP' => { type: 'varchar', length: 5, nullable: true }
  }.freeze

  # Strategies for handling erroneous data within the CSV
  # abort: Application exits with fatal error
  # nullify: Application replaces erroneous data with NULL
  # skip: If erroneous data is found, the entire row is skipped
  STRATEGIES = [:abort, :nullify, :skip]

  attr_reader :batch_size, :output_filename, :strategy

  def initialize(input_filename:, batch_size: 10, output_filename: nil, strategy: :nullify)
    @input_filename = input_filename
    @output_filename = output_filename || "#{File.basename(input_filename, '.*')}.sql"
    @batch_size = batch_size
    self.strategy = strategy
    @queue = Queue.new
  end

  # InvalidStrategyException
  #
  # thrown when an invalid strategy is selected
  class InvalidStrategyException < StandardError
    def initialize(new_strategy)
      "#{new_strategy} is not a valid strategy. Valid stategies are #{STRATEGIES}"
    end
  end

  def strategy=(new_strategy)
    raise InvalidStrategyException(new_strategy) unless STRATEGIES.include? new_strategy

    @strategy = new_strategy
  end

  def valid_field?(column, value)
    return true if VALID_COLUMNS[column][:nullable] && value.nil?

    case VALID_COLUMNS[column][:type]
    when 'int'
      return true if /^\d*$/.match? value
    when 'decimal'
      # Must be of decimal format
      return false unless /^\d*\.?\d*$/.match?(value)

      # Must meet precision requirements, if present.
      # N.B. This is commented out because the database will automatically
      # truncate values with greater precision than supported by the datatype.
      #return false unless VALID_COLUMNS[column][:precision] &&
      #                   value.split('.').join.length <= VALID_COLUMNS[column][:precision]

      # Must meet scale requirements, if present
      return true if VALID_COLUMNS[column][:scale] &&
                     value.split('.').first.length <= VALID_COLUMNS[column][:precision] - VALID_COLUMNS[column][:scale]
    when 'varchar'
      return false unless value.is_a? String

      return true if VALID_COLUMNS[column][:length] && value.length <= VALID_COLUMNS[column][:length]
    end
  end

  # Preprocesses rows based on selected strategy
  def preprocess_row(row)
    fields = row.to_h
    columns.each do |column|
      next if valid_field? column, fields[column]

      case strategy
      when :nullify
        fields[column] = nil
      when :skip
        return nil
      else
        abort('Error in CSV data detected. Aborting')
      end
    end
    fields
  end

  def generate_insert_string(row)
    fields = preprocess_row(row)
    insert_string = columns.inject('(') do |build_string, header|
      field = if fields[header].nil?
                'NULL'
              elsif VALID_COLUMNS[header][:type] == 'varchar'
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
    "INSERT INTO vdw.census_demog (#{columns.join(',')}) VALUES \n".gsub(/STATE/, '"STATE"')
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

  def columns
    @columns ||= VALID_COLUMNS.keys
  end

  def headers
    return @headers if @headers

    csv_headers ||= CSV.foreach(@input_filename).first
    csv_headers[0].gsub!("\xEF\xBB\xBF", '')
    @headers = csv_headers
  end
end

census_demog_csvs.each do |filename|
  CensusDemogGenerator.new(input_filename: filename).process
end
