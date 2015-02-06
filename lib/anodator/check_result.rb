require "anodator/rule"

module Anodator
  class CheckResult
    attr_reader :target_numbers, :message, :level

    def initialize(target_numbers, message, level)
      @target_numbers = [target_numbers].flatten
      @message        = message.to_s
      @level          = level

      if @target_numbers.size.zero?
        raise ArgumentError.new("target numbers cannot be blank")
      end
      if @message.split(//).size.zero?
        raise ArgumentError.new("message cannot be blank")
      end
      unless Rule::ERROR_LEVELS.values.include?(level)
        raise ArgumentError.new("level must be #{Rule::ERROR_LEVEL_NAMES.join(", ")}")
      end
    end

    def to_s
      buf = "[#{Rule.level_expression(@level)}]\t"
      buf += @message + " |#{@target_numbers.join(", ")}|"
    end

    def method_missing(message, *args)
      if message.to_s =~ /(\A[a-zA-Z_]+)\?\Z/
        if Rule::ERROR_LEVELS.keys.include?($1.to_sym)
          return Rule::ERROR_LEVELS[$1.to_sym] == @level
        end
      end

      super
    end
  end
end
