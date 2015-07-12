require "anodator/validator/base"
require "bigdecimal"

module Anodator
  module Validator
    class NumericValidator < Base
      valid_option_keys :only_integer, :greater_than, :greater_than_or_equal_to
      valid_option_keys :less_than, :less_than_or_equal_to, :equal_to, :not_equal_to
      default_options :only_integer => false

      def initialize(target_expression, options = { })
        super(target_expression, options)

        [:greater_than, :greater_than_or_equal_to,
          :less_than, :less_than_or_equal_to,
          :equal_to, :not_equal_to].each do |key|
          @options[key] = proxy_value(@options[key]) unless @options[key].nil?
        end
      end

      def validate
        if allow_blank?
          return true if target_value.split(//).size.zero?
        end

        # check format
        if @options[:only_integer]
          regexp = /^-?\d+$/
        else
          regexp = /^-?\d+(\.\d+)?$/
        end
        return false unless regexp.match target_value

        # convert BigDecimal value
        value = BigDecimal.new(target_value)

        @options.each do |option, configuration|
          case option
          when :greater_than
            return false unless value > BigDecimal.new(configuration.value.to_s)
          when :greater_than_or_equal_to
            return false unless value >= BigDecimal.new(configuration.value.to_s)
          when :less_than
            return false unless value < BigDecimal.new(configuration.value.to_s)
          when :less_than_or_equal_to
            return false unless value <= BigDecimal.new(configuration.value.to_s)
          when :equal_to
            return false unless value == BigDecimal.new(configuration.value.to_s)
          when :not_equal_to
            return false unless value != BigDecimal.new(configuration.value.to_s)
          end
        end

        return true
      end
    end
  end
end
