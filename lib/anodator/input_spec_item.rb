module Anodator
  class InputSpecItem
    TYPE_STRING  = "STRING"
    TYPE_NUMERIC = "NUMERIC"
    TYPE_DATE    = "DATE"

    attr_reader :number, :name, :type

    def initialize(number, name, type = TYPE_STRING)
      if number.nil? || number.to_s.split(//).size.zero?
        raise ArgumentError.new("number cannot be blank")
      end
      if name.nil? || name.to_s.split(//).size.zero?
        raise ArgumentError.new("name cannot be blank")
      end
      unless [TYPE_STRING, TYPE_NUMERIC, TYPE_DATE].include?(type)
        raise ArgumentError.new("unknown data type '#{type}'")
      end

      @number = number
      @name = name
      @type = type
    end

    def ==(other)
      if other.is_a? InputSpecItem
        self.number == other.number
      else
        return false
      end
    end
  end
end
