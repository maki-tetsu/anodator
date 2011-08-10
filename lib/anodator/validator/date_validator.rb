require "anodator/validator/base"
require "date"

module Anodator
  module Validator
    class DateValidator < Base
      FORMAT_SCANNER_REGEXP = /((YY(?:YY)?)|(M(?![YMD]))|(MM)|(D(?![YMD]))|(DD))/

      valid_option_keys :from, :to, :format, :base_year
      default_options :format => "YYYY-MM-DD", :base_year => 2000

      def initialize(target_expression, options = { })
        super(target_expression, options)

        # format check
        date_regexp_holders

        if !@options[:from].nil? && !@options[:from].is_a?(Date)
          date = parse_date(@options[:from].to_s)
          if date.nil?
            raise ArgumentError.new("Invalid date expression '#{@options[:from]}'")
          else
            @options[:from] = date
          end
        end

        if !@options[:to].nil? && !@options[:to].is_a?(Date)
          date = parse_date(@options[:to].to_s)
          if date.nil?
            raise ArgumentError.new("Invalid date expression '#{@options[:to]}'")
          else
            @options[:to] = date
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
              return false if configuration > date
            when :to
              return false if configuration < date
            end
          end

          return true
        rescue ArgumentError
          # invalid date expression
          return false
        end
      end

      def from
        if @options[:from]
          return @options[:from].dup
        else
          return nil
        end
      end

      def to
        if @options[:to]
          return @options[:to].dup
        else
          return nil
        end
      end

      def format
        return @options[:format].dup
      end

      # parse string with :format option
      #
      # not matched return nil
      def parse_date(date_expression)
        return nil unless match_data = date_regexp.match(date_expression)

        index = 0
        date_hash = date_regexp_holders.inject({ }) do |hash, key|
          index += 1
          hash[key] = match_data[index].to_i

          next hash
        end
        # for short year
        if date_hash.keys.include?(:short_year)
          date_hash[:year] = @options[:base_year].to_i + date_hash[:short_year]
        end

        return Date.new(date_hash[:year], date_hash[:month], date_hash[:day])
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

        return Regexp.new("^#{regexp_string}$")
      end
      private :date_regexp

      def date_regexp_holders
        scans = @options[:format].scan FORMAT_SCANNER_REGEXP
        year_count, month_count, day_count = 0, 0, 0
        holders = scans.map do |scan|
          case scan.first
          when "YYYY"
            year_count += 1
            :year
          when "YY"
            year_count += 1
            :short_year
          when "MM", "M"
            month_count += 1
            :month
          when "DD", "D"
            day_count += 1
            :day
          end
        end
        unless holders.size == 3
          raise ArgumentError.new("date format must be contained year(YYYY or YY), month(MM or M) and day(DD or D).")
        end
        unless year_count == 1 && month_count == 1 && day_count == 1
          raise ArgumentError.new("date format must be contained year(YYYY or YY), month(MM or M) and day(DD or D).")
        end

        return holders
      end
      private :date_regexp_holders
    end
  end
end
