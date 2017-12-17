require 'anodator/input_spec_item'
require 'anodator/anodator_error'

module Anodator
  class DuplicatedInputSpecItemError < AnodatorError; end
  class UnknownTargetExpressionError < AnodatorError; end
  class SourceDataNotProvidedError < AnodatorError; end

  # InputSpec
  class InputSpec
    CALCULATION_HOLDER_REGEXP = /\[\[([^\]]+)\]\]/

    include Common

    def initialize(spec_items = [])
      @spec_items  = []
      @source      = nil
      @number_dict = {}
      @name_dict   = {}

      check_instances([[spec_items, Array]], ArgumentError)
      setup_input_spec_items(spec_items)
    end

    def setup_input_spec_items(spec_items)
      spec_items.each do |spec|
        next unless %i[number name].all? { |k| spec.key?(k) }
        push_spec_items(build_input_spec_item(spec))
      end
    end
    private :setup_input_spec_items

    def build_input_spec_item(spec)
      if spec[:type].nil?
        InputSpecItem.new(spec[:number], spec[:name])
      else
        InputSpecItem.new(spec[:number], spec[:name], spec[:type])
      end
    end
    private :build_input_spec_item

    def push_spec_items(spec)
      check_duplicate_key(spec.number, spec.name)

      @spec_items << spec
      index = @spec_items.size - 1
      @number_dict[spec.number] = { item: spec, index: index }
      @name_dict[spec.name]     = { item: spec, index: index }
    end
    private :push_spec_items

    def check_duplicate_key(num, name)
      msg = nil
      msg = "duplicated number spec item '#{num}'" if @number_dict.key?(num)
      msg = "duplicated name spec item '#{name}'" if @name_dict.key?(name)

      raise DuplicatedInputSpecItemError, msg unless msg.nil?
    end
    private :check_duplicate_key

    def source=(source)
      msg = 'source should respond to :[] method'
      raise ArgumentError, msg unless source.respond_to? :[]

      @source = source
    end

    def clear_source
      @source = nil
    end

    def value_at(index)
      raise SourceDataNotProvidedError if @source.nil?
      msg = "accessed by index '#{index}'"
      raise UnknownTargetExpressionError, msg if @spec_items[index].nil?

      @source[index].to_s
    end

    def value_at_by_number(number)
      raise SourceDataNotProvidedError if @source.nil?
      msg = "accessed by number '#{number}'"
      raise UnknownTargetExpressionError, msg unless @number_dict.key?(number)

      value_at(@number_dict[number][:index])
    end

    def value_at_by_name(name)
      raise SourceDataNotProvidedError if @source.nil?
      msg = "accessed by name '#{name}'"
      raise UnknownTargetExpressionError, msg unless @name_dict.key?(name)

      value_at(@name_dict[name][:index])
    end

    def value_by_calculation(calculation)
      holders = check_calculation_expression(calculation)
      values = convert_values_from_holders(holders)
      calculation.gsub!(CALCULATION_HOLDER_REGEXP) { |m| values[m] }

      value = eval(calculation)
      value = value.to_s('F') if value.is_a? BigDecimal

      return value
    rescue StandardError
      msg = "accessed by calculation '#{calculation}'"
      raise UnknownTargetExpressionError, msg
    end
    private :value_by_calculation

    def convert_values_from_holders(holders)
      holders.each_with_object({}) do |expression, hash|
        value = self[expression]
        spec = spec_item_by_expression(expression)

        hash["[[#{expression}]]"] =
          if spec.type == InputSpecItem::TYPE_NUMERIC
            %|BigDecimal("#{value}")|
          else
            %("#{value}")
          end
      end
    end
    private :convert_values_from_holders

    def [](target_expression)
      raise SourceDataNotProvidedError if @source.nil?
      return value_at(target_expression) if target_expression.is_a? Integer

      if target_expression =~ /^CALC::(.+)$/
        return value_by_calculation(Regexp.last_match(1))
      end

      value_at_by_number(target_expression)
    rescue UnknownTargetExpressionError
      value_at_by_name(target_expression)
    end

    def spec_item_at(index)
      msg = "accessed by index '#{index}'"
      raise UnknownTargetExpressionError, msg if @spec_items[index].nil?

      @spec_items[index].dup
    end

    def spec_item_at_by_number(number)
      msg = "accessed by number '#{number}'"
      raise UnknownTargetExpressionError, msg unless @number_dict.key?(number)

      @number_dict[number][:item].dup
    end

    def spec_item_at_by_name(name)
      msg = "accessed by name '#{name}'"
      raise UnknownTargetExpressionError, msg unless @name_dict.key?(name)

      @name_dict[name][:item].dup
    end

    def spec_items_by_calculation(calculation)
      holders = check_calculation_expression(calculation)
      holders.map do |expression|
        spec_item_by_expression(expression)
      end
    end
    private :spec_items_by_calculation

    def spec_item_by_expression(target_expression)
      return spec_item_at(target_expression) if target_expression.is_a? Integer

      if target_expression =~ /^CALC::(.+)$/
        return spec_items_by_calculation(Regexp.last_match(1))
      end

      return spec_item_at_by_number(target_expression)
    rescue UnknownTargetExpressionError
      return spec_item_at_by_name(target_expression)
    end

    # return all holders specs
    def check_calculation_expression(calculation)
      if calculation =~ /(@|require|load|;)/
        raise ArgumentError, "Invalid calcuation expression '#{calcuation}'"
      end

      calculation.scan(CALCULATION_HOLDER_REGEXP)
                 .flatten.map do |target_expression|
        spec_item_by_expression(target_expression)
        next target_expression
      end
    end
  end
end
