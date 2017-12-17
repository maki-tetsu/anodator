module Anodator
  class InputSpecItem
    TYPE_STRING  = 'STRING'.freeze
    TYPE_NUMERIC = 'NUMERIC'.freeze
    TYPE_DATE    = 'DATE'.freeze

    attr_reader :number, :name, :type

    def initialize(number, name, type = TYPE_STRING)
      if number.nil? || number.to_s.split(//).size.zero?
        raise ArgumentError, 'number cannot be blank'
      end
      if name.nil? || name.to_s.split(//).size.zero?
        raise ArgumentError, 'name cannot be blank'
      end
      unless [TYPE_STRING, TYPE_NUMERIC, TYPE_DATE].include?(type)
        raise ArgumentError, "unknown data type '#{type}'"
      end

      @number = number
      @name = name
      @type = type
    end

    def ==(other)
      if other.is_a? InputSpecItem
        number == other.number
      else
        false
      end
    end
  end
end
