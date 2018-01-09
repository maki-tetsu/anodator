module Anodator
  # OutputSpec.
  class OutputSpec
    TARGETS = {
      DATA: 'DATA',
      ERROR: 'ERROR'
    }.freeze

    VALID_SYMBOL_ITEMS = %i[
      target_numbers
      target_names
      target_values
      error_message
      error_level
      error_count
      warning_count
      error_and_warning_count
    ].freeze

    attr_reader   :items, :target, :include_no_error
    attr_accessor :separator, :value_separator

    def initialize(items = [], options = {})
      setup_defaults
      @items            = items.to_a

      options.each do |key, opt|
        case key
        when :target
          @target = opt
        when :include_no_error
          @include_no_error = !!opt
        when :separator, :value_separator
          @separator = opt.to_s
        else
          raise ArgumentError, "unknown option #{key}."
        end
      end

      unless TARGETS.values.include?(@target)
        raise ArgumentError, "unknown target option value #{@target}."
      end

      check_items
    end

    def setup_defaults
      @target           = TARGETS[:ERROR]
      @include_no_error = false
      @separator        = ' '
      @value_separator  = ''
    end
    private :setup_defaults

    def validate_configuration
      @items.each do |item|
        Validator::Base.values.spec_item_at_by_number(item) if item.is_a? String
      end
    rescue UnknownTargetExpressionError => e
      raise InvalidConfiguration, e.to_s
    end

    def check_items
      @items.each do |item|
        next unless item.is_a? Symbol
        unless VALID_SYMBOL_ITEMS.include?(item)
          raise ArgumentError, "unknown item symbol #{item}"
        end
      end
    end
    private :check_items

    def generate(input_spec_with_values, check_results)
      if @target == TARGETS[:DATA]
        generate_data(input_spec_with_values, check_results)
      else # @target == TARGETS[:ERROR]
        generate_error(input_spec_with_values, check_results)
      end
    end

    def generate_data(input_spec_with_values, check_results)
      buf = []
      buf << @items.map do |item|
        if item.is_a? Symbol
          case item
          when :error_count
            next check_results.map do |result|
              result.error? ? true : nil
            end.compact.size.to_s
          when :warning_count
            next check_results.map do |result|
              result.warning? ? true : nil
            end.compact.size.to_s
          when :error_and_warning_count
            next check_results.size.to_s
          else
            next ''
          end
        else # data
          next input_spec_with_values[item]
        end
      end

      buf
    end
    private :generate_data

    def generate_error(input_spec_with_values, check_results)
      buf = []

      if check_results.size.zero?
        if @include_no_error
          buf << @items.map do |item|
            if item.is_a? Symbol
              case item
              when :error_count, :warning_count, :error_and_warning_count
                next '0'
              else
                next ''
              end
            else # data
              next input_spec_with_values[item]
            end
          end
        end
      else
        check_results.each do |check_result|
          buf << @items.map do |item|
            if item.is_a? Symbol
              case item
              when :target_numbers
                next check_result.target_numbers.join(@separator)
              when :target_names
                next check_result.target_numbers.map do |number|
                  input_spec_with_values.spec_item_at_by_number(number).name
                end.join(@separator)
              when :target_values
                next check_result.target_numbers.map do |number|
                  input_spec_with_values[number]
                end.join(@value_separator)
              when :error_message
                next check_result.message
              when :error_level
                next check_result.level.to_s
              when :error_count
                next check_results.map do |result|
                  result.error? ? true : nil
                end.compact.size.to_s
              when :warning_count
                next check_results.map do |result|
                  result.warning? ? true : nil
                end.compact.size.to_s
              when :error_and_warning_count
                next check_results.size.to_s
              else
                next ''
              end
            else # data
              next input_spec_with_values[item]
            end
          end
        end
      end

      buf
    end
    private :generate_error
  end
end
