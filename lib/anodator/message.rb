require "anodator/anodator_error"

module Anodator
  class UnknownMessageAttributeError < AnodatorError ; end

  # Message is error message builder.
  #
  # Message is generated with formated string for expand several keywords.
  # Message#expand method is expand keywords by data_provider suppried by parameter.
  class Message < String
    # message
    attr_reader :template

    def initialize(template_message)
      @template = template_message.to_s

      if @template.split(//).size.zero?
        raise ArgumentError.new("template_message cannot be blank")
      end
    end

    # expand message with data_provider
    #
    # message keyword is expressed +[[target_expression::attribute]]+.
    # data_provider is data source for current check target.
    #
    # - target_expression: specify target.
    # - attribute: actual printed value
    #   - name:   target name
    #   - number: target number
    #   - value:  target actual data
    def expand(data_provider)
      @template.gsub(/\[\[([^:]+)::([^\]]+)\]\]/) do
        spec_item = data_provider.spec_item_by_expression($1)
        case $2
        when "name"
          spec_item.name
        when "number"
          spec_item.number
        when "value"
          data_provider[$1]
        else
          raise UnknownMessageAttributeError.new("Unknown message attribute '#{$2}'")
        end
      end
    end

    def validate_configuration
      @template.gsub(/\[\[([^:]+)::([^\]]+)\]\]/) do
        Validator::Base.values.spec_item_by_expression($1)
        unless %W(name number value).include?($2)
          raise UnknownMessageAttributeError.new("Unknown message attribute '#{$2}'")
        end
      end
    rescue UnknownTargetExpressionError, UnknownMessageAttributeError => e
      raise InvalidConfiguration.new(e.to_s)
    end
  end
end
