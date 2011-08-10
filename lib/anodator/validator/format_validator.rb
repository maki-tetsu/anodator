require "anodator/validator/base"
require "anodator/validator/configuration_error"

module Anodator
  module Validator
    class FormatValidator < Base
      valid_option_keys :format

      def initialize(target_expression, options = { })
        super(target_expression, options)

        if @options[:format].is_a? String
          @options[:format] = Regexp.new("#{@options[:format]}")
        end
      end

      def validate
        if target_value.split(//).size.zero?
          if allow_blank?
            return true
          end
        end

        unless @options[:format].is_a? Regexp
          raise ConfigurationError.new(":format option must be Regexp object")
        end

        if @options[:format].match target_value
          return true
        else
          return false
        end
      end

      def format
        return @options[:format].dup
      end
    end
  end
end
