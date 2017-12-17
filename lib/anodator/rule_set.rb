require 'anodator/rule'

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
        raise ArgumentError, 'rule must be Anodator::Rule object'
      end
    end

    alias << add_rule

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

    attr_reader :results

    def validate_configuration
      @rules.each(&:validate_configuration)
    end

    def to_s
      @rules.map(&:to_s).join("\n")
    end
  end
end
