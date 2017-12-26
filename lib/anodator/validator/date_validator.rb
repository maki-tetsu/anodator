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

      valid_option_keys :from, :to, :format, :base_year
      default_options format: 'YYYY-MM-DD', base_year: 2000

      def initialize(target_expression, options = {})
        super(target_expression, options)

        check_format
        setup_period_options
      end

      def setup_period_options
        %i[from to].each do |key|
          next unless @options.key?(key)
          @options[key] = proxy_value(@options[key])
          next unless @options[key].direct? && !@options[key].value.is_a?(Date)

          date = parse_date(@options[key].value.to_s)
          msg = "Invalid date expression '#{@options[key].value}'"
          raise ArgumentError, msg if date.nil?

          @options[key] = proxy_value(date)
        end
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

      def from_date
        from ? parse_date(from.value) : nil
      end

      def to_date
        to ? parse_date(to.value) : nil
      end

      # parse string with :format option
      #
      # not matched return nil
      def parse_date(date_expression)
        return date_expression if date_expression.is_a? Date
        return nil unless date_regexp.match(date_expression)

        date_hash = date_regexp_holders.each_with_object({})
                                       .with_index(1) do |(key, hash), i|
          hash[key] = Regexp.last_match[i].to_i
        end
        if date_hash.key?(:short_year)
          date_hash[:year] = @options[:base_year].to_i + date_hash[:short_year]
        end

        Date.new(date_hash[:year], date_hash[:month], date_hash[:day])
      end
      private :parse_date

      def date_regexp
        date_regexp_holders # check format string

        regexp_string = @options[:format].dup
        regexp_string.sub!(/YYYY/, '(\d{4})')
        regexp_string.sub!(/YY/,   '(\d{2})')
        regexp_string.sub!(/MM/,   '(\d{2})')
        regexp_string.sub!(/M/,    '(\d{1,2})')
        regexp_string.sub!(/DD/,   '(\d{2})')
        regexp_string.sub!(/D/,    '(\d{1,2})')

        Regexp.new("^#{regexp_string}$")
      end
      private :date_regexp

      def date_regexp_holders
        parse_date_format
      end
      private :date_regexp_holders

      def parse_date_format
        @options[:format].scan(FORMAT_SCANNER_REGEXP).map do |scan|
          HOLDER_DEFS[scan.first]
        end
      end
      private :parse_date_format

      def check_format
        msg = 'date format must be contained year(YYYY or YY), ' \
              'month(MM or M) and day(DD or D).'
        holders = parse_date_format

        checked_holders = holders.inject([]) do |array, holder|
          raise ArgumentError, msg if holder.nil?
          array << (holder == :short_year ? :year : holder)
        end

        raise ArgumentError, msg unless checked_holders.size == 3
        raise ArgumentError, msg unless checked_holders.uniq!.nil?
      end
      private :check_format
    end
  end
end
