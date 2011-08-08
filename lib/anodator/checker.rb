require "anodator/input_spec"
require "anodator/rule_set"
require "anodator/output_spec"
require "anodator/anodator_error"

module Anodator
  class Checker
    def initialize(input_spec, rule_set, default_output_spec, configuration_check = false)
      @input_spec   = input_spec
      @rule_set     = rule_set
      @output_specs = [default_output_spec]

      unless @input_spec.is_a? InputSpec
        raise ArgumentError.new("input_spec must be InputSpec object")
      end
      unless @rule_set.is_a? RuleSet
        raise ArgumentError.new("rule_set must be RuleSet object")
      end
      unless @output_specs.first.is_a? OutputSpec
        raise ArgumentError.new("default_output_spec must be OutputSpec object")
      end

      Validator::Base.values = @input_spec

      validate_configuration if configuration_check
    end

    def validate_configuration
      # RuleSet
      @rule_set.validate_configuration
      # OutputSpec
      @output_specs.each do |spec|
        spec.validate_configuration
      end
    end

    def add_output_spec(output_spec, configuration_check = false)
      unless output_spec.is_a? OutputSpec
        raise ArgumentError.new("output_spec must be OutputSpec object")
      end
      @output_specs << output_spec

      validate_configuration if configuration_check
    end

    def run(values)
      @input_spec.source = values
      @rule_set.check_all
      @output_specs.map do |spec|
        spec.generate(@input_spec, @rule_set.results)
      end
    end
  end
end
