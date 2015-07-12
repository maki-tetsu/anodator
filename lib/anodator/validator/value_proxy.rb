module Anodator
  module Validator
    class ValueProxy
      REGEXP_INDIRECT = /\A\[\[([^\]]+)\]\]\Z/

      def initialize(value, validator)
        @value = value
        @validator = validator
        @indirect = false

        if matched = REGEXP_INDIRECT.match(@value.to_s)
          @indirect = true
          @value = matched[1]
        end
      end

      def indirect?
        return @indirect
      end

      def direct?
        return !@indirect
      end

      def value
        if direct?
          return @value
        else
          return @validator.argument_value_at(@value)
        end
      end

      def to_s
        if direct?
          return @value.to_s
        else
          return "#{@value}(Indirect)"
        end
      end
    end
  end
end
