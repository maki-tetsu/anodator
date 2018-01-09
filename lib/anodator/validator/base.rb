require 'anodator/validator/value_proxy'

module Anodator
  module Validator
    # +Validator::Base+ is basic class for validations
    class Base
      # value of target for validation
      @@values = nil

      # data source set
      @@data_source_set = nil

      # valid option keys
      #
      # :allow_blank options are all available options in Validator.
      # In addition, Validator All you need to consider the case of the blank.
      @valid_option_keys = %i[allow_blank description]

      # default options
      #
      # Is used as the initial value was not set when you create a new Validator.
      @default_options   = { allow_blank: false }

      # target specify value
      attr_reader :target

      # option values
      attr_reader :options

      # @@valid_option_keys = [:allow_blank]

      # class methods
      class << self
        # set and/or get valid option keys
        def valid_option_keys(*option_keys)
          # initialize from superclass
          if @valid_option_keys.nil?
            @valid_option_keys = superclass.valid_option_keys
          end

          unless option_keys.size.zero?
            option_keys.each do |key|
              if @valid_option_keys.include?(key)
                raise ArgumentError, "Validator already has option for '#{key}'"
              else
                @valid_option_keys << key
              end
            end
          end

          @valid_option_keys.dup
        end

        # set and/or get default options
        def default_options(options = nil)
          # initialize from superclass
          @default_options = superclass.default_options if @default_options.nil?

          unless options.nil?
            unless options.is_a? Hash
              raise ArgumentError, 'default_options must call with Hash'
            end
            options.each do |option, default_value|
              if @valid_option_keys.include?(option)
                @default_options[option] = default_value
              else
                raise ArgumentError, "Unknown option '#{option}'"
              end
            end
          end

          @default_options.dup
        end

        # Set the data to be checked.
        #
        # Data to be checked can be set to any object that responds to [].
        def values=(values)
          if values.respond_to?(:[])
            @@values = values
          else
            raise ArgumentError, 'values must be respond to [] method for validations.'
          end
        end

        # Get the data to be checked
        def values
          @@values
        end

        # Set the data source with check.
        def data_source_set=(data_source_set)
          msg = 'data_source_set must be Anodator::DataSourceSet'
          raise ArgumentError, msg unless data_source_set.is_a? DataSourceSet

          @@data_source_set = data_source_set
        end

        def data_source_set
          @@data_source_set
        end
      end

      # initializer
      #
      # Specify +options+ as an additional parameter to hold the verification
      # and other options for specifying the +target_expression+ be verified.
      # The default options are optional and will be an empty hash.
      # Key to use additional parameters are stored in class variable
      # +valid_option_keys+.
      # If necessary add additional parameters for the new validator is defined
      # in the inherited class to add.
      def initialize(target_expression, options = {})
        if target_expression.to_s.length.zero?
          raise ArgumentError, 'target cannot be nil or blank'
        else
          @target = target_expression.to_s
        end
        @options = {}
        merge_options!(self.class.default_options)
        merge_options!(options)
      end

      # validation method
      #
      # +validate+ method must be defined in a class that inherits.
      # In the +validate+ method implements the verification method.
      # Can be implemented to return a boolean value to the final,
      # +valid?+ The method used is called.
      def validate
        raise NoMethodError, "must define method 'validate'"
      end

      # Call the +validate+ method to return a boolean value accordingly
      #
      # If any exception occurs in the +validate+ method displays the contents
      # to standard error. Then raise same error.
      def valid?
        validate
      end

      # merge options
      #
      # If the key parameter is illegal to throw an ArgumentError.
      def merge_options!(options)
        options.each do |key, value|
          if self.class.valid_option_keys.include?(key)
            @options[key] = value
          else
            raise ArgumentError, "Unknown option key '#{key}'."
          end
        end
      end

      private :merge_options!

      # target_value
      #
      # always return String object use to_s method
      def target_value
        @@values[target].to_s
      end

      def argument_value_at(name_or_index)
        @@values[name_or_index].to_s
      end

      def data_source_at(expression)
        identifier, key, column = expression.split(':', 3)
        @@data_source_set.fetch(identifier, key, column)
      end

      def allow_blank?
        @options[:allow_blank]
      end

      def description
        @options[:description]
      end

      def proxy_value(target)
        ValueProxy.new(target, self)
      end
      private :proxy_value

      def to_s(level = 4, _step = 2)
        (' ' * level) + "- #{self.class}(#{description})"
      end

      def validate_configuration
        @@values.spec_item_by_expression(@target)
      rescue UnknownTargetExpressionError => e
        raise InvalidConfiguration, e.to_s
      end
    end
  end
end
