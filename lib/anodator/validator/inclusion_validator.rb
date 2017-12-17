require 'anodator/validator/base'

module Anodator
  module Validator
    class InclusionValidator < Base
      valid_option_keys :in

      def validate
        if allow_blank?
          return true if target_value.split(//).size.zero?
        end

        unless @options[:in].respond_to? :include?
          raise ConfigurationError, ':in option must be responed_to include?'
        end

        @options[:in].include?(target_value)
      end
    end
  end
end
