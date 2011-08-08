module Anodator
  class OutputSpec
    TARGET_DATA  = "DATA"
    TARGET_ERROR = "ERROR"

    VALID_SYMBOL_ITEMS = [
                          :target_numbers,
                          :target_names,
                          :target_values,
                          :error_message,
                          :error_level,
                          :error_count,
                          :warning_count,
                          :error_and_warning_count,
                         ]

    attr_reader :items, :target, :include_no_error

    def initialize(items = [], options = { })
      @items            = items.to_a
      @target           = TARGET_ERROR
      @include_no_error = false

      options.each do |key, opt|
        case key
        when :target
          @target = opt
        when :include_no_error
          @include_no_error = !!opt
        else
          raise ArgumentError.new("unknown option #{key}.")
        end
      end

      unless [TARGET_DATA, TARGET_ERROR].include?(@target)
        raise ArgumentError.new("unknown target option value #{@target}.")
      end

      check_items
    end

    def validate_configuration
      @items.each do |item|
        if item.is_a? String
          Validator::Base.values.spec_item_at_by_number(item)
        end
      end
    rescue UnknownTargetExpressionError => e
      raise InvalidConfiguration.new(e.to_s)
    end

    def check_items
      @items.each do |item|
        if item.is_a? Symbol
          unless VALID_SYMBOL_ITEMS.include?(item)
            raise ArgumentError.new("unknown item symbol #{item}")
          end
        end
      end
    end
    private :check_items

    def generate(input_spec_with_values, check_results)
      if @target == TARGET_DATA
        generate_data(input_spec_with_values, check_results)
      else # @target == TARGET_ERROR
        generate_error(input_spec_with_values, check_results)
      end
    end

    def generate_data(input_spec_with_values, check_results)
      buf = []
      buf << @items.map do |item|
        if item.is_a? Symbol
          case item
          when :error_count
            next check_results.map { |result|
              result.error? ? true : nil
            }.compact.size.to_s
          when :warning_count
            next check_results.map { |result|
              result.warning? ? true : nil
            }.compact.size.to_s
          when :error_and_warning_count
            next check_results.size.to_s
          else
            next ""
          end
        else # data
          next input_spec_with_values[item]
        end
      end

      return buf
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
                next "0"
              else
                next ""
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
                next check_result.target_numbers.join(" ")
              when :target_names
                next check_result.target_numbers.map { |number|
                  input_spec_with_values.spec_item_at_by_number(number).name
                }.join(" ")
              when :target_values
                next check_result.target_numbers.map { |number|
                  input_spec_with_values[number]
                }.join(" ")
              when :error_message
                next check_result.message
              when :error_level
                next check_result.level.to_s
              when :error_count
                next check_results.map { |result|
                  result.error? ? true : nil
                }.compact.size.to_s
              when :warning_count
                next check_results.map { |result|
                  result.warning? ? true : nil
                }.compact.size.to_s
              when :error_and_warning_count
                next check_results.size.to_s
              else
                next ""
              end
            else # data
              next input_spec_with_values[item]
            end
          end
        end
      end

      return buf
    end
    private :generate_error
  end
end
