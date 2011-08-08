require "anodator/rule"

module Anodator
  class CheckResult
    attr_reader :target_numbers, :message, :level

    def initialize(target_numbers, message, level)
      @target_numbers = target_numbers.to_a
      @message        = message.to_s
      @level          = level

      if @target_numbers.size.zero?
        raise ArgumentError.new("target numbers cannot be blank")
      end
      if @message.split(//).size.zero?
        raise ArgumentError.new("message cannot be blank")
      end
      unless [Rule::LEVEL_ERROR, Rule::LEVEL_WARNING].include?(level)
        raise ArgumentError.new("level must be ERROR or WARNING")
      end
    end

    def to_s
      buf = "[      ]\t"
      if @level == Rule::LEVEL_WARNING
        buf = "[WARING]\t"
      else
        buf = "[ERROR ]\t"
      end
      buf += @message + " |#{@target_numbers.join(", ")}|"
    end

    def error?
      return Rule::LEVEL_ERROR == @level
    end

    def warning?
      return Rule::LEVEL_WARNING == @level
    end
  end
end
