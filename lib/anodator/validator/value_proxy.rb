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
        @indirect
      end

      def direct?
        !@indirect
      end

      def value
        if direct?
          @value
        else
          @validator.argument_value_at(@value)
        end
      end

      def to_s
        if direct?
          @value.to_s
        else
          "#{@value}(Indirect)"
        end
      end
    end
  end
end
