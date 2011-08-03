require "anodator/validator/base"
require "anodator/validator/configuration_error"

module Anodator
  module Validator
    class LengthValidator < Base
      valid_option_keys :in, :maximum, :minimum, :is

      def validate
        length = target_value.split(//).size

        if allow_blank?
          return true if length.zero?
        end

        @options.each do |option, configuration|
          case option
          when :in
            if configuration.is_a? Range
              return false unless configuration.include?(length)
            else
              raise ConfigurationError.new(":in option value must be Range object")
            end
          when :maximum
            return false if length > configuration
          when :minimum
            return false if length < configuration
          when :is
            return false if length != configuration
          end
        end

        return true
      end
    end
  end
end
