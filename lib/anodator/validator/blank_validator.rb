require "anodator/validator/base"

module Anodator
  module Validator
    # blank validator
    #
    # This is the Validator to validate whether the value is not present.
    class BlankValidator < Base
      def validate
        return target_value.split(//).size.zero?
      end
    end
  end
end
