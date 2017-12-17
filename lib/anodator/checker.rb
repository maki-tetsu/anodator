require 'anodator/input_spec'
require 'anodator/rule_set'
require 'anodator/output_spec'
require 'anodator/anodator_error'

module Anodator
  # Checker class.
  class Checker
    def initialize(input_spec, rule_set, output_spec, config_check = false)
      validate_initialize_params(input_spec, rule_set, output_spec)

      @input_spec = input_spec
      @rule_set = rule_set
      @output_specs = [output_spec]
      Validator::Base.values = @input_spec

      validate_configuration if config_check
    end

    def validate_initialize_params(input_spec, rule_set, output_spec)
      [
        [input_spec, InputSpec],
        [rule_set, RuleSet],
        [output_spec, OutputSpec]
      ].each do |c|
        raise ArgumentError, "#{c[0]} must be #{c[1]}" unless c[0].is_a? c[1]
      end
    end

    def validate_configuration
      @rule_set.validate_configuration
      @output_specs.each(&:validate_configuration)
    end

    def add_output_spec(output_spec, configuration_check = false)
      unless output_spec.is_a? OutputSpec
        raise ArgumentError, 'output_spec must be OutputSpec object'
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

    def rule_info
      @rule_set.to_s
    end
  end
end
