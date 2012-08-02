require 'cassandra'

module Cassequence
  class Config

    attr_accessor :host
    attr_accessor :port

    attr_accessor :key_space 

    attr_accessor :pool_size

    def initialize
      self.host = '127.0.0.1'
      self.port = 9160
      self.key_space = nil
    end

    def new_clients
      @cass_clients = []
      pool_size.times do
        @cass_clients << Cassandra.new(self.key_space, "#{self.host}:#{self.port}")
      end
      @cass_clients
    end

    def cassandra_clients
      @cass_clients || new_clients
    end

    def client(reconnect = false)
      if self.host and self.port and self.key_space
        if reconnect
          @cassandra_client = Cassandra.new(self.key_space, "#{self.host}:#{self.port}")
        else
          @cassandra_client ||= Cassandra.new(self.key_space, "#{self.host}:#{self.port}")
        end
      else
        raise "I need a host, port, and key_space"        
      end
      validate_key_space
      @cassandra_client
    end

    def find_or_create_column_family(name)
      if thing = client.column_families[name]
        thing.comparator_type = 'org.apache.cassandra.db.marshal.DateType'
      else
        client.add_column_family Cassandra::ColumnFamily.new(keyspace: self.key_space, name: name, comparator_type: 'org.apache.cassandra.db.marshal.DateType')
      end
      true
    rescue
      false
    end

    def validate_key_space
      begin
        @cassandra_client.keyspaces.include?(self.key_space) # will raise an error 
      rescue Exception => e
        @cassandra_client.disable_node_auto_discovery!
        @cassandra_client.keyspaces.include?(self.key_space) # will raise an error 
      end
    end

  end
end
