require "anodator/input_spec_item"
require "anodator/anodator_error"

module Anodator
  class DuplicatedInputSpecItemError < AnodatorError; end
  class UnknownTargetExpressionError < AnodatorError; end
  class SourceDataNotProvidedError < AnodatorError; end

  class InputSpec
    CALCULATION_HOLDER_REGEXP = /\[\[([^\]]+)\]\]/

    def initialize(spec_items = [])
      @spec_items  = []
      @source      = nil
      @number_dict = { }
      @name_dict   = { }

      unless spec_items.is_a? Array
        raise ArgumentError.new("initialized by Array by Hash(key is :name and :number")
      end

      spec_items.each do |spec_item_values|
        if spec_item_values.keys.include?(:number) &&
            spec_item_values.keys.include?(:name)
          if spec_item_values.keys.include?(:type) &&
              !spec_item_values[:type].nil?
            push_spec_items(InputSpecItem.new(spec_item_values[:number],
                                              spec_item_values[:name],
                                              spec_item_values[:type]))
          else
            push_spec_items(InputSpecItem.new(spec_item_values[:number],
                                              spec_item_values[:name]))
          end
        end
      end
    end

    def push_spec_items(spec)
      if @number_dict.keys.include?(spec.number)
        raise DuplicatedInputSpecItemError.new("duplicated number spec item '#{spec.number}'")
      end
      if @name_dict.keys.include?(spec.name)
        raise DuplicatedInputSpecItemError.new("duplicated name spec item '#{spec.name}'")
      end
      @spec_items << spec
      index = @spec_items.size - 1
      @number_dict[spec.number] = { :item => spec, :index => index }
      @name_dict[spec.name]     = { :item => spec, :index => index }
    end
    private :push_spec_items

    def source=(source)
      if source.respond_to? :[]
        @source = source
      else
        raise ArgumentError.new("source should respond to :[] method")
      end
    end

    def clear_source
      @source = nil
    end

    def value_at(index)
      raise SourceDataNotProvidedError.new if @source.nil?

      if @spec_items[index].nil?
        raise UnknownTargetExpressionError.new("accessed by index '#{index}'")
      else
        return @source[index].to_s
      end
    end

    def value_at_by_number(number)
      raise SourceDataNotProvidedError.new if @source.nil?

      if @number_dict.keys.include?(number)
        return value_at(@number_dict[number][:index])
      else
        raise UnknownTargetExpressionError.new("accessed by number '#{number}'")
      end
    end

    def value_at_by_name(name)
      raise SourceDataNotProvidedError.new if @source.nil?

      if @name_dict.keys.include?(name)
        return value_at(@name_dict[name][:index])
      else
        raise UnknownTargetExpressionError.new("accessed by name '#{name}'")
      end
    end

    def value_by_calculation(calculation)
      holders = check_calculation_expression(calculation)

      values = holders.inject({ }) do |hash, expression|
        value = self[expression]
        spec = spec_item_by_expression(expression)

        case spec.type
        when InputSpecItem::TYPE_NUMERIC
          hash["[[#{expression}]]"] = %Q|BigDecimal("#{value}")|
        else # String, other
          hash["[[#{expression}]]"] = %Q|"#{value}"|
        end
        next hash
      end

      calculation.gsub!(CALCULATION_HOLDER_REGEXP) do |match|
        values[match]
      end

      value = eval(calculation)
      value = value.to_s("F") if value.is_a? BigDecimal

      return value
    rescue UnknownTargetExpressionError => ex
      raise
    rescue => ex
      raise UnknownTargetExpressionError.new("accessed by calculation '#{calculation}'")
    end
    private :value_by_calculation

    def [](target_expression)
      raise SourceDataNotProvidedError.new if @source.nil?

      if target_expression.is_a? Integer
        return value_at(target_expression)
      elsif /^CALC::(.+)$/.match target_expression
        return value_by_calculation($1)
      else
        begin
          return value_at_by_number(target_expression)
        rescue UnknownTargetExpressionError
          return value_at_by_name(target_expression)
        end
      end
    end

    def spec_item_at(index)
      if @spec_items[index].nil?
        raise UnknownTargetExpressionError.new("accessed by index '#{index}'")
      else
        @spec_items[index].dup
      end
    end

    def spec_item_at_by_number(number)
      if @number_dict.keys.include?(number)
        return @number_dict[number][:item].dup
      else
        raise UnknownTargetExpressionError.new("accessed by number '#{number}'")
      end
    end

    def spec_item_at_by_name(name)
      if @name_dict.keys.include?(name)
        return @name_dict[name][:item].dup
      else
        raise UnknownTargetExpressionError.new("accessed by name '#{name}'")
      end
    end

    def spec_items_by_calculation(calculation)
      holders = check_calculation_expression(calculation)
      holders.map do |expression|
        spec_item_by_expression(expression)
      end
    end
    private :spec_items_by_calculation

    def spec_item_by_expression(target_expression)
      if target_expression.is_a? Integer
        return spec_item_at(target_expression)
      elsif /^CALC::(.+)$/.match target_expression
        return spec_items_by_calculation($1)
      else
        begin
          return spec_item_at_by_number(target_expression)
        rescue UnknownTargetExpressionError
          return spec_item_at_by_name(target_expression)
        end
      end
    end

    # return all holders specs
    def check_calculation_expression(calculation)
      if /(@|require|load|;)/.match calculation
        return ArgumentError.new("Invalid calcuation expression '#{calcuation}'")
      end

      calculation.scan(CALCULATION_HOLDER_REGEXP).flatten.map do |target_expression|
        spec_item_by_expression(target_expression)
        next target_expression
      end
    end
  end
end
