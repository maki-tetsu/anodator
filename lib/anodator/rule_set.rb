require "anodator/rule"

module Anodator
  class RuleSet
    def initialize
      @rules   = []
      @results = []
    end

    def add_rule(rule)
      if rule.is_a? Rule
        @rules << rule
      else
        raise ArgumentError.new("rule must be Anodator::Rule object")
      end
    end

    alias_method :<<, :add_rule

    def check_all
      @results = []

      if @rules.count.zero?
        return false
      else
        @rules.each do |rule|
          if result = rule.check
            @results << result
          end
        end

        return true
      end
    end

    def results
      return @results
    end

    def validate_configuration
      @rules.each do |rule|
        rule.validate_configuration
      end
    end
  end
end
