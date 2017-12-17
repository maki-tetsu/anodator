require 'csv'

module Anodator
  module Utils
    # load input_spec from csv file
    #
    # File encoding: UTF-8
    # Columns:
    #   - column identification(string)
    #   - column name(string)
    #   - column type(STRING, NUMERIC or DATE, default is STRING)
    # Arguments:
    #   - file_path: file path for input spec.
    # Return:
    #   InputSpec instance
    def self.load_input_spec_from_csv_file(file_path)
      first = true
      header = nil
      spec = []
      CSV.read(file_path).each do |row|
        # skip header
        if first
          header = row
          first = false
          next
        end
        spec << { number: row[0], name: row[1], type: row[2] }
      end

      InputSpec.new(spec)
    end

    # load output_spec from csv file
    #
    # When target is TARGET_ERROR generate output line by one error,
    # when target is TARGET_DATA generate output line by one data.
    # When set include_no_error is true and target is TARGET_DATA,
    # generate output line has no error.
    #
    # File encoding: UTF-8
    # Columns:
    #   - output column identification(string)
    #   - output special column(string)
    #     - target_numbers(for error)
    #     - target_names(for one error)
    #     - target_values(for one error)
    #     - error_message(for one error)
    #     - error_level(for one error)
    #     - error_count(for one data)
    #     - warning_count(for one data)
    #     - error_and_warning_count(for one data)
    # Arguments:
    #   - file_path: file path for output spec.
    #   - target: OutputSpec::TARGET_ERROR or OutputSpec::TARGET_DATA
    #   - include_no_error: true or false(default false)
    # Return:
    #   OutputSpec instance
    def self.load_output_spec_from_csv_file(file_path,
                                            target = Anodator::OutputSpec::TARGET_ERROR,
                                            include_no_error = false)
      first = true
      header = nil
      spec = []
      CSV.read(file_path).each do |row|
        # skip header
        if first
          header = row
          first = false
          next
        end
        spec << if row.first.nil? || row.first.split(//).length.zero?
                  row.last.to_sym
                else
                  row.first.to_s
                end
      end

      Anodator::OutputSpec.new(spec, target: target, include_no_error: include_no_error)
    end

    # options reader for option values for validator specs
    #
    # When value is 'true' or 'false', convert true or false instance.
    # The others set to string.
    #
    # Arguments:
    #   - row: validator line string
    #   - options: default options
    #   - options_index_from: index for option column be started on row(default: 4)
    # Return:
    #   Hash
    def self.options_reader(row, options = {}, options_index_from = 4)
      if row.size > options_index_from
        row[options_index_from..-1].each do |column|
          next if column.nil?
          key, value = column.split(':', 2)
          case value
          when 'true', 'false'
            options[key.to_sym] = eval(value)
          else
            options[key.to_sym] = value
          end
        end
      end

      options
    end

    # load validators from csv file
    #
    # File encoding: UTF-8
    # Columns:
    #   - validator identification(string)
    #   - validation name(string)
    #   - validator type(string)
    #   - target expression(string)
    #   - options...
    # Return:
    #   Hash for validators(key is identification, value is validator)
    def self.load_validators_from_csv_file(file_path)
      first = true
      header = nil
      validators = {}

      CSV.read(file_path).each do |row|
        # skip header
        if first
          header = row
          first = false
          next
        end

        if validators.keys.include?(row[0])
          raise ArgumentError, "Duplicated validator number '#{row[0]}'!"
        end

        options = options_reader(row, description: row[1])

        validator = nil

        case row[2]
        when 'presence'
          validator = Validator::PresenceValidator
        when 'blank'
          validator = Validator::BlankValidator
        when 'date'
          validator = Validator::DateValidator
        when 'format'
          validator = Validator::FormatValidator
        when 'inclusion'
          validator = Validator::InclusionValidator
          options[:in] = options[:in].split(',') unless options[:in].nil?
        when 'length'
          validator = Validator::LengthValidator
        when 'numeric'
          validator = Validator::NumericValidator
        when 'complex'
          options[:validators] = row[3].split(',').map do |validator_number|
            validators[validator_number]
          end
          validators[row[0]] = Validator::ComplexValidator.new(options)
        else
          raise ArgumentError, "Unknown validator type '#{row[2]}'!"
        end

        validators[row[0]] = validator.new(row[3], options) if validator
      end

      validators
    end

    # load rule_set from csv file
    #
    # File encoding: UTF-8
    # Columns:
    #   - rule identification(string)
    #   - rule description(string)
    #   - target expression(column identification or column name)
    #   - validator identification
    #   - prerequisite validator identification(allow blank and multiple validator identification)
    #   - error level(ERROR or WARNING)
    #   - error message holder(string)
    # Return:
    #   RuleSet instance
    def self.load_rule_from_csv_file(file_path, validators)
      first = true
      header = nil
      rule_set = RuleSet.new

      CSV.read(file_path).each do |row|
        # skip header
        if first
          header = row
          first = false
          next
        end

        description = row[1]
        target_expression = row[2].split(',')
        validator = validators[row[3]]
        if !row[4].nil? && row[4].include?(',')
          prerequisite = row[4].split(',').map do |validator_id|
            raise "Unknown validator identifier '#{validator_id}'" if validators[validator_id].nil?
            next validators[validator_id]
          end
        else
          prerequisite = validators[row[4]]
        end
        raise "Unknown validator identifier '#{row[3]}'" if validator.nil?
        if !row[4].nil? && prerequisite.nil?
          raise "Unknown validator identifier '#{row[4]}'"
        end
        if Rule::ERROR_LEVEL_NAMES.values.include?(row[5])
          level = Rule::ERROR_LEVELS[Rule::ERROR_LEVEL_NAMES.index(row[5])]
        else
          raise "Unknown error type '#{row[5]}'"
        end
        message = Message.new(row[6])

        rule_set <<
          Rule.new(target_expression,
                   message,
                   validator,
                   prerequisite,
                   level,
                   description)
      end

      rule_set
    end
  end
end
