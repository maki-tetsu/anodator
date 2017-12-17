require 'anodator/validator/base'

module Anodator
  module Validator
    # presence validator
    #
    # This is the Validator to validate whether the value is present.
    class PresenceValidator < Base
      def validate
        !target_value.split(//).size.zero?
      end
    end
  end
end
