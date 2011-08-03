require "anodator/validator/base"
require "anodator/validator/configuration_error"

module Anodator
  module Validator
    class FormatValidator < Base
      valid_option_keys :format

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
    end
  end
end
