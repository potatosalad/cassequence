require 'cassandra'
require "cassequence/version"
require 'cassequence/config'
require 'cassequence/column'
require 'cassequence/criteria'

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
      @config.client.find_or_create_column_family(name)
    end

  end
end