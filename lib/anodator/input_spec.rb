require "anodator/input_spec_item"
require "anodator/anodator_error"

module Anodator
  class DuplicatedInputSpecItemError < AnodatorError; end
  class UnknownTargetExpressionError < AnodatorError; end
  class SourceDataNotProvidedError < AnodatorError; end

  class InputSpec
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
          push_spec_items(InputSpecItem.new(spec_item_values[:number],
                                            spec_item_values[:name]))
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

    def [](target_expression)
      raise SourceDataNotProvidedError.new if @source.nil?

      if target_expression.is_a? Fixnum
        return value_at(target_expression)
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

    def spec_item_by_expression(target_expression)
      if target_expression.is_a? Fixnum
        return spec_item_at(target_expression)
      else
        begin
          return spec_item_at_by_number(target_expression)
        rescue UnknownTargetExpressionError
          return spec_item_at_by_name(target_expression)
        end
      end
    end
  end
end
