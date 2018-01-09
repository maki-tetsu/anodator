require 'anodator/data_source'

module Anodator
  # duplicated DataSource Identifier error.
  class DuplicatedDataSourceIdentifierError < StandardError; end
  # DataSourceSet is a set of DataSource
  class DataSourceSet
    def initialize
      @data_sources = {}
    end

    def <<(data_source)
      msg = 'data_source must be DataSource.'
      raise ArgumentError, msg unless data_source.is_a? DataSource

      check_duplicate_key(data_source)
    end

    def fetch(identifier, key, column)
      identifier = identifier.to_s.to_sym
      key = key.to_s.to_sym
      column = column.to_s.to_sym

      @data_sources[identifier][key][column]
    end

    private

    def check_duplicate_key(data_source)
      key = data_source.identifier.to_sym
      raise DuplicatedDataSourceIdentifierError if @data_sources.key?(key)

      @data_sources[key] = data_source
    end
  end
end
