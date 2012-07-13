require 'cassandra'

module Cassequence
  class Config

    attr_accessor :host
    attr_accessor :port
    attr_accessor :username
    attr_accessor :password

    attr_accessor :key_space 
    attr_accessor :column_family

    def initialize
      self.key_space = nil
      self.column_family = nil
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

  end
end


