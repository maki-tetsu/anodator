require "anodator/validator/base"
require "anodator/validator/configuration_error"

module Anodator
  module Validator
    class FormatValidator < Base
      # ALL_ZENKAKU_REGEXP = /(?:\xEF\xBD[\xA1-\xBF]|\xEF\xBE[\x80-\x9F])|[\x20-\x7E]/
      ALL_ZENKAKU_REGEXP = /(?:[\xEF\xBD\xA1-\xEF\xBD\xBF]|[\xEF\xBE\x80-\xEF\xBE\x9F])|[\x20-\x7E]/

      valid_option_keys :format, :all_zenkaku
      default_options :all_zenkaku => false

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


        if @options[:all_zenkaku]
          return target_value !~ ALL_ZENKAKU_REGEXP
        else
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

      def format
        return @options[:format].dup
      end
    end
  end
end
