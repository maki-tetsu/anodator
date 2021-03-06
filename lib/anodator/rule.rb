require 'anodator/message'
require 'anodator/validator'
require 'anodator/check_result'

module Anodator
  # Check rule
  #
  # Rule has target expressions, prerequisite, validator and message.
  # "Prerequisite" is represented by the Validator.
  class Rule
    # Check levels
    #
    # default levels are error and warning.
    # You can add any levels.
    ERROR_LEVELS = {
      error: 2, # ERROR
      warning: 1, # WARNING
    }

    # Check level names
    #
    # Check level name labels
    ERROR_LEVEL_NAMES = {
      error: 'ERROR',
      warning: 'WARNING'
    }

    attr_reader :target_expressions, :message, :validator, :prerequisite, :level, :description

    def self.add_error_level(value, symbol, label)
      # value check
      raise 'Error level value must be Integer' unless value.is_a? Integer
      raise 'Error level value must be greater than zero' unless value > 0
      raise "Error level value #{value} already exists" if ERROR_LEVELS.values.include?(value)
      # symbol check
      raise 'Error level symbol must be symbol' unless symbol.is_a? Symbol
      raise "Error level symbol #{symbol} already exists" if ERROR_LEVELS.keys.include?(symbol)
      # label check
      raise 'Error level label must be string' unless label.is_a? String
      raise "Error level label #{label} already exists" if ERROR_LEVEL_NAMES.values.include?(label)

      # check OK
      ERROR_LEVELS[symbol] = value
      ERROR_LEVEL_NAMES[symbol] = label
    end

    def self.remove_error_level(symbol)
      # symbol check
      raise "Unknown rror level symbol #{symbol}" unless ERROR_LEVELS.keys.include?(symbol)
      # count check
      raise 'Error levels must be atleast one value' if ERROR_LEVELS.size == 1

      # check OK
      ERROR_LEVELS.delete(symbol)
      ERROR_LEVEL_NAMES.delete(symbol)
    end

    def initialize(target_expressions, message, validator, prerequisite = nil, level = ERROR_LEVELS.values.sort.last, description = nil)
      @target_expressions = [target_expressions].flatten
      @message            = message
      @validator          = validator
      @prerequisite       = prerequisite
      @level              = level
      @description        = description

      if @target_expressions.size.zero?
        raise ArgumentError, 'target expressions cannot be blank'
      end
      raise ArgumentError, 'message cannot be blank' if @message.nil?
      raise ArgumentError, 'validator cannot be blank' if @validator.nil?
      unless ERROR_LEVELS.values.include?(@level)
        raise ArgumentError, "level must be #{ERROR_LEVEL_NAMES.join(', ')}."
      end
      if @prerequisite.is_a? Array
        @prerequisite = Validator::ComplexValidator.new(validators: @prerequisite)
      end
    end

    # check values depend on prerequisite and validator
    #
    # When invalid, return CheckResult object, but when valid
    # return nil.
    def check
      unless @prerequisite.nil?
        return nil unless @prerequisite.valid?
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
      raise InvalidConfiguration, e.to_s
    end

    def level_expression
      Rule.level_expression(@level)
    end

    def self.level_expression(level)
      if ERROR_LEVELS.values.include?(level)
        return ERROR_LEVEL_NAMES[ERROR_LEVELS.key(level)]
      end

      nil
    end

    def to_s
      target_names = @target_expressions.map { |te| Validator::Base.values.spec_item_by_expression(te).name }.join(',')
      buf = <<_EOD_
Description: #{@description.nil? ? 'None.' : @description}
  Targets: #{target_names}
  Message: #{@message.template}
  Level: #{level_expression}
  Validator:
#{@validator}
  Prerequisite:
#{@prerequisite.nil? ? '    - (None)' : @prerequisite.to_s}
_EOD_
    end
  end
end
