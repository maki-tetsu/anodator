module Anodator
  class InputSpecItem
    attr_reader :number, :name

    def initialize(number, name)
      if number.nil? || number.to_s.split(//).size.zero?
        raise ArgumentError.new("number cannot be blank")
      end
      if name.nil? || name.to_s.split(//).size.zero?
        raise ArgumentError.new("name cannot be blank")
      end

      @number = number
      @name = name
    end
  end
end
