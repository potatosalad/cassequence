require 'cassandra'

module Cassequence
  class Config

    attr_accessor :host
    attr_accessor :port
    attr_accessor :username
    attr_accessor :password

    attr_accessor :key_space 

    def initialize
      self.key_space = nil
      self.username = nil
      self.password = nil
    end

    def client(reconnect = false)
      if reconnect
        @cassandra_client = Cassandra.new(self.key_space, "#{self.host}:#{self.port}")
      else
        @cassandra_client ||= Cassandra.new(self.key_space, "#{self.host}:#{self.port}")
      end
    end

    def find_or_create_column_family(name)
      if thing = client.column_families[name]
        thing.comparator_type = 'org.apache.cassandra.db.marshal.DateType'
      else
        client.add_column_family Cassandra::ColumnFamily.new(keyspace: config.key_space, name: name, comparator_type: 'org.apache.cassandra.db.marshal.DateType')
      end
      true
    end

  end
end


