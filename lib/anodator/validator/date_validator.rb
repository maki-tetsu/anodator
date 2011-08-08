require "anodator/validator/base"
require "date"

module Anodator
  module Validator
    class DateValidator < Base
      valid_option_keys :from, :to

      def initialize(target_expression, options = { })
        options.each do |key, value|
          case key
          when :from, :to
            options[key] = Date.parse(value) unless value.is_a? Date
          end
        end

        super(target_expression, options)
      end

      def validate
        if allow_blank?
          return true if target_value.split(//).size.zero?
        end

        # check format
        return false unless /^(\d{4})[-\/](\d{1,2})[-\/](\d{1,2})$/.match target_value

        begin
          date = Date.parse(target_value)
        rescue ArgumentError
          # invalid date expression
          return false
        end

        @options.each do |option, configuration|
          case option
          when :from
            return configuration <= date
          when :to
            return configuration >= date
          end
        end

        return true
      end

      def from
        return @options[:from].dup
      end

      def to
        return @options[:to].dup
      end
    end
  end
end
