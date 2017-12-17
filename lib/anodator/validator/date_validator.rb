require 'anodator/validator/base'
require 'date'

module Anodator
  module Validator
    class DateValidator < Base
      FORMAT_SCANNER_REGEXP = /((YY(?:YY)?)|(M(?![YMD]))|(MM)|(D(?![YMD]))|(DD))/

      valid_option_keys :from, :to, :format, :base_year
      default_options format: 'YYYY-MM-DD', base_year: 2000

      def initialize(target_expression, options = {})
        super(target_expression, options)

        # format check
        date_regexp_holders

        %i[from to].each do |key|
          next if @options[key].nil?
          @options[key] = proxy_value(@options[key])
          next unless @options[key].direct? && !@options[key].value.is_a?(Date)
          date = parse_date(@options[key].value.to_s)
          if date.nil?
            raise ArgumentError, "Invalid date expression '#{@options[key].value}'"
          else
            @options[key] = proxy_value(date)
          end
        end
      end

      def validate
        if allow_blank?
          return true if target_value.split(//).size.zero?
        end

        begin
          # check format
          return false unless date = parse_date(target_value)

          @options.each do |option, configuration|
            case option
            when :from
              return false if parse_date(configuration.value) > date
            when :to
              return false if parse_date(configuration.value) < date
            end
          end

          return true
        rescue ArgumentError
          # invalid date expression
          return false
        end
      end

      def from
        @options[:from].dup if @options[:from]
      end

      def to
        @options[:to].dup if @options[:to]
      end

      def format
        @options[:format].dup
      end

      # parse string with :format option
      #
      # not matched return nil
      def parse_date(date_expression)
        return date_expression if date_expression.is_a? Date
        return nil unless match_data = date_regexp.match(date_expression)

        index = 0
        date_hash = date_regexp_holders.inject({}) do |hash, key|
          index += 1
          hash[key] = match_data[index].to_i

          next hash
        end
        # for short year
        if date_hash.keys.include?(:short_year)
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
        scans = @options[:format].scan FORMAT_SCANNER_REGEXP
        year_count = 0
        month_count = 0
        day_count = 0
        holders = scans.map do |scan|
          case scan.first
          when 'YYYY'
            year_count += 1
            :year
          when 'YY'
            year_count += 1
            :short_year
          when 'MM', 'M'
            month_count += 1
            :month
          when 'DD', 'D'
            day_count += 1
            :day
          end
        end
        unless holders.size == 3
          raise ArgumentError, 'date format must be contained year(YYYY or YY), month(MM or M) and day(DD or D).'
        end
        unless year_count == 1 && month_count == 1 && day_count == 1
          raise ArgumentError, 'date format must be contained year(YYYY or YY), month(MM or M) and day(DD or D).'
        end

        holders
      end
      private :date_regexp_holders
    end
  end
end
