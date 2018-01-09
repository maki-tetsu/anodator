module Anodator
  module Validator
    class ValueProxy
      REGEXP_INDIRECT = /\A\[\[([^\]]+)\]\]\Z/
      REGEXP_DATA_SOURCE = /\A\{\{([^\}]+)\}\}\Z/

      def initialize(value, validator)
        @value = value
        @validator = validator
        @indirect = false
        @data_source = false

        if matched = REGEXP_INDIRECT.match(@value.to_s)
          @indirect = true
          @value = matched[1]
        end

        if matched = REGEXP_DATA_SOURCE.match(@value.to_s)
          @data_source = true
          @value = machted[1]
        end
      end

      def indirect?
        @indirect
      end

      def direct?
        !@indirect
      end

      def data_source?
        @data_source
      end

      def value
        if indirect?
          @validator.argument_value_at(@value)
        elsif data_source?
          @validator.data_source_at(@value)
        else # if direct?
          @value
        end
      end

      def to_s
        if indirect?
          "#{@value}(Indirect)"
        elsif data_source?
          "#{@value}(DataSource)"
        else
          @value.to_s
        end
      end
    end
  end
end
