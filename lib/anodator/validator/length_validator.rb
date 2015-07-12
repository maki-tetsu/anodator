require "anodator/validator/base"
require "anodator/validator/configuration_error"

module Anodator
  module Validator
    class LengthValidator < Base
      valid_option_keys :in, :maximum, :minimum, :is

      def initialize(target_expression, options = { })
        super(target_expression, options)

        [:maximum, :minimum, :is].each do |key|
          @options[key] = proxy_value(@options[key]) unless @options[key].nil?
        end
      end

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
            return false if length > configuration.value.to_i
          when :minimum
            return false if length < configuration.value.to_i
          when :is
            return false if length != configuration.value.to_i
          end
        end

        return true
      end
    end
  end
end
