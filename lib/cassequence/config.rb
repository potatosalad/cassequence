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
      self.pool_size = 10
    end

    # def new_clients
    #   @cass_clients = []
    #   pool_size.times do
    #     @cass_clients << Cassandra.new(self.key_space, "#{self.host}:#{self.port}", {:retries => 10, :timeout => 15, :connect_timeout => 15})
    #   end
    #   @cass_clients
    # end

    # def cassandra_clients
    #   @cass_clients || new_clients
    # end

    # def next_client
    #   @@current ||= 0
    #   cassandra_clients[(@@current = (@@current + 1) % pool_size)]
    # end

    def client(reconnect = false)
      
      if self.host and self.port and self.key_space
        if reconnect
          Thread.current[:cass_client] = Cassandra.new(self.key_space, "#{self.host}:#{self.port}", {:retries => 10, :timeout => 15, :connect_timeout => 15})
        else
          Thread.current[:cass_client] ||= Cassandra.new(self.key_space, "#{self.host}:#{self.port}", {:retries => 10, :timeout => 15, :connect_timeout => 15})
        end
      else
        raise "I need a host, port, and key_space"        
      end
      validate_key_space
      Thread.current[:cass_client]
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
        raise 'invalid keyspace' unless Thread.current[:cass_client].keyspaces.include?(self.key_space) 
      rescue Exception => e
        Thread.current[:cass_client].disable_node_auto_discovery!
        raise 'invalid keyspace' unless Thread.current[:cass_client].keyspaces.include?(self.key_space) 
      end
    end

  end
end