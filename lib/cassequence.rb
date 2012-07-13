require 'cassandra'
require "cassequence/version"
require 'cassequence/config'
require 'cassequence/column'

module Cassequence

  class << self

    def config=(data)
      @config = data
    end

    def config
      @config ||= Config.new
      @config
    end

    def configure(&proc)
      @config ||= Config.new
      yield @config
    end

    def client
      @config.client
    end

    def find_or_create_column_family(name)
      if thing = client.column_families[name]
        thing.comparator_type = 'org.apache.cassandra.db.marshal.DateType'
      else
        client.add_column_family Cassandra::ColumnFamily.new(keyspace: config.key_space, name: name, comparator_type: 'org.apache.cassandra.db.marshal.DateType')
      end

    end

  end
end