require 'anodator/validator/base'
require 'date'

module Anodator
  module Validator
    # Validator for Date expression.
    class DateValidator < Base
      FORMAT_SCANNER_REGEXP =
        /((YY(?:YY)?)|(M(?![YMD]))|(MM)|(D(?![YMD]))|(DD))/
      HOLDER_DEFS = {
        'YYYY' => :year,
        'YY' => :short_year,
        'MM' => :month,
        'M' => :month,
        'DD' => :day,
        'D' => :day
      }.freeze
      HOLDERS = %w[YYYY YY MM M DD D].freeze
      REGEXPS = %w[(\d{4}) (\d{2}) (\d{2}) (\d{1,2}) (\d{2}) (\d{1,2})].freeze

      valid_option_keys :from, :to, :format, :base_year
      default_options format: 'YYYY-MM-DD', base_year: 2000

      def initialize(target_expression, options = {})
        super(target_expression, options)

        check_format
        setup_period_options
      end

      def validate
        return true if allow_blank? && target_value.split(//).size.zero?
        date = parse_date(target_value)
        return false unless date

        validate_period(date)
      rescue ArgumentError # invalid date expression
        return false
      end

      def validate_period(date)
        valid_from = from ? from_date <= date : true
        valid_to = to ? to_date >= date : true

        valid_from && valid_to
      end

      def from
        @options[:from].dup
      end

      def to
        @options[:to].dup
      end

      def format
        @options[:format].dup
      end

      def base_year
        @options[:base_year].to_i
      end

      def from_date
        from ? parse_date(from.value) : nil
      end

      def to_date
        to ? parse_date(to.value) : nil
      end

      private

      def setup_period_options
        %i[from to].each do |key|
          setup_date_option(key) if @options.key?(key)
        end
      end

      def setup_date_option(key)
        option = proxy_value(@options[key])
        if option.direct? && !option.value.is_a?(Date)
          date = parse_date(option.value.to_s)
          msg = "Invalid date expression '#{option.value}'"
          raise ArgumentError, msg if date.nil?

          option = proxy_value(date)
        end

        @options[key] = option
      end

      def parse_date(date_expression)
        return date_expression if date_expression.is_a? Date
        return nil unless date_regexp.match(date_expression)

        date_hash = date_regexp_holders.each_with_object({})
                                       .with_index(1) do |(key, hash), i|
          hash[key] = Regexp.last_match[i].to_i
        end
        convert_short_year(date_hash)
        Date.new(date_hash[:year], date_hash[:month], date_hash[:day])
      end

      def convert_short_year(hash)
        hash[:year] = base_year + hash[:short_year] if hash.key?(:short_year)
      end

      def date_regexp
        regexp_string = HOLDERS.each_with_index.inject(format) do |s, (h, i)|
          s.sub(/#{h}/, REGEXPS[i])
        end

        /^#{regexp_string}$/
      end

      def date_regexp_holders
        format.scan(FORMAT_SCANNER_REGEXP).map do |scan|
          HOLDER_DEFS[scan.first]
        end
      end

      def check_format
        msg = 'date format must be contained year(YYYY or YY), ' \
              'month(MM or M) and day(DD or D).'

        checked_holders = date_regexp_holders.inject([]) do |array, holder|
          raise ArgumentError, msg if holder.nil?
          array << (holder == :short_year ? :year : holder)
        end

        raise ArgumentError, msg unless checked_holders.size == 3
        raise ArgumentError, msg unless checked_holders.uniq!.nil?
      end
    end
  end
end
