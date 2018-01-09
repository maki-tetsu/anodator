module Anodator
  # Unknown key on DataSource error.
  class UnknownKeyOnDataSourceError < StandardError; end
  # DataSource is external data source for check input datas.
  #
  # datas = {
  #   'key1' => {
  #     name: 'taro',
  #     age: 20
  #   },
  #   'key2' => {
  #     name: 'jiro',
  #     age: 35
  #   }
  # }
  # # datas object must be respond to :[].
  # ds = DataSource.new('name', datas)
  class DataSource
    VALID_OPTIONS = {
      on_nil: %i[raise_error nil],
      on_exception: %i[raise_error nil]
    }.freeze

    DEFAULT_OPTIONS = {
      on_nil: :nil,
      on_exception: :raise_error
    }.freeze

    attr_reader :identifier

    def initialize(identifier, datas, options = {})
      msg = 'datas must be respond to :[]'
      raise ArgumentError, msg unless datas.respond_to?(:[])
      options = merge_default_options(options)
      validate_options(options)

      @identifier = identifier.to_s
      @datas = datas
      @options = options
    end

    def [](key)
      @datas[key].nil? ? on_nil_value : @datas[key]
    rescue UnknownKeyOnDataSourceError
      raise
    rescue StandardError => e
      on_exception(e)
    end

    private

    def merge_default_options(options)
      DEFAULT_OPTIONS.each_with_object(options.dup) do |(k, v), merged|
        merged[k] ||= v
      end
    end

    def validate_options(options)
      validate_option_keys(options)
      validate_option_values(options)
    end

    def validate_option_keys(options)
      options.each_key do |key|
        msg = "Invalid option '#{key.inspect}'"
        raise ArgumentError, msg unless VALID_OPTIONS.key?(key)
      end
    end

    def validate_option_values(options)
      options.each do |key, value|
        msg = "Invalid #{key.inspect} option value '#{value.inspect}'"
        raise ArgumentError, msg unless VALID_OPTIONS[key].include?(value)
      end
    end

    def on_nil_value
      return nil if @options[:on_nil] == :nil
      raise UnknownKeyOnDataSourceError, 'DataSource nil'
    end

    def on_exception(e)
      return nil if @options[:on_exception] == :nil
      raise UnknownKeyOnDataSourceError, e
    end
  end
end
