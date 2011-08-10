require "anodator/message"
require "anodator/validator"
require "anodator/check_result"

module Anodator
  # Check rule
  #
  # Rule has target expressions, prerequisite, validator and message.
  # "Prerequisite" is represented by the Validator.
  class Rule
    # Check level ERROR
    LEVEL_ERROR   = 2
    # Check level WARNING
    LEVEL_WARNING = 1

    attr_reader :target_expressions, :message, :validator, :prerequisite, :level

    def initialize(target_expressions, message, validator, prerequisite = nil, level = LEVEL_ERROR)
      @target_expressions = target_expressions.to_a
      @message            = message
      @validator          = validator
      @prerequisite       = prerequisite
      @level              = level

      if @target_expressions.size.zero?
        raise ArgumentError.new("target expressions cannot be blank")
      end
      if @message.nil?
        raise ArgumentError.new("message cannot be blank")
      end
      if @validator.nil?
        raise ArgumentError.new("validator cannot be blank")
      end
      unless [LEVEL_ERROR, LEVEL_WARNING].include?(@level)
        raise ArgumentError.new("level must be ERROR or WARNING")
      end
    end

    # check values depend on prerequisite and validator
    #
    # When invalid, return CheckResult object, but when valid
    # return nil.
    def check
      unless @prerequisite.nil?
        unless @prerequisite.valid?
          return nil
        end
      end

      if @validator.valid?
        return nil
      else
        numbers = @target_expressions.map do |target_expression|
          Validator::Base.values.spec_item_by_expression(target_expression).number
        end

        CheckResult.new(numbers,
                        @message.expand(Validator::Base.values),
                        @level)
      end
    end

    def validate_configuration
      @target_expressions.each do |target_expression|
        Validator::Base.values.spec_item_by_expression(target_expression)
      end
      @message.validate_configuration
      @validator.validate_configuration
      @prerequisite.validate_configuration unless @prerequisite.nil?
    rescue UnknownTargetExpressionError => e
      raise InvalidConfiguration.new(e.to_s)
    end
  end
end