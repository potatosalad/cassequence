require 'cassandra'
require 'cassequence/config'
require 'cassequence/column'
require "cassequence/version"
require 'cassequence/criteria'
require 'cassequence/extensions/time'
require 'cassequence/extensions/float'
require 'cassequence/extensions/string'
require 'cassequence/extensions/boolean'
require 'cassequence/extensions/integer'

module Cassequence

  class << self

    def config=(data)
      if data.class == Cassequence::Config or data == nil
        @config = data  
      else
        raise "I only accept the Cassequence::Config class"
      end
    end

    def config
      @config ||= Config.new
      @config
    end

    def configure(&proc)
      yield config
    end

    def client(reconnect = false)
      config.client(reconnect)
    end
    
    def find_or_create_column_family(name)
      config.find_or_create_column_family(name)
    end

  end
end