require 'anodator/validator/configuration_error'

module Anodator
  module Validator
    # ComplexValidator behaves like a single Validator what contains multiple
    # Validators.
    class ComplexValidator < Base
      # Combine logical OR of each Validators
      LOGIC_OR  = 'OR'.freeze
      # Combine logical AND of each Validators
      LOGIC_AND = 'AND'.freeze

      valid_option_keys :validators, :logic
      default_options logic: LOGIC_AND

      def initialize(options = {})
        super('dummy', options)
      end

      def validate
        if @options[:validators].nil?
          raise ConfigurationError, 'ComplexValidator must have validators option'
        end
        case @options[:logic]
        when LOGIC_OR
          @options[:validators].each do |validator|
            return true if validator.valid?
          end
          return false
        when LOGIC_AND
          @options[:validators].each do |validator|
            return false unless validator.valid?
          end
          return true
        else
          raise ConfigurationError, "Unknown logic option '#{@options[:logic]}"
        end
      end

      def logic_expression
        if @options[:logic] == LOGIC_OR
          'OR'
        elsif @options[:logic] == LOGIC_AND
          'AND'
        end
      end

      def validate_configuration
        # target check skip
      end

      def to_s(level = 2, step = 2)
        buf = "#{super(level, step)} LOGIC: #{logic_expression}\n"
        buf += @options[:validators].map do |validator|
          validator.to_s(level + step, step)
        end.join("\n")
      end
    end
  end
end
