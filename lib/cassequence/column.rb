require 'cassequence/extensions/float'
require 'cassequence/extensions/string'
require 'cassequence/extensions/integer'


module Cassequence::Column
  module ClassMethods

    attr_accessor :column_family_name

    attr_accessor :default_types

    def where(hash)
      Cassequence::Criteria.new(hash, self)
    end
    
    def field(key, options = {})
      if type = options[:type]
        self.default_types[key.to_sym] = type if type.class == Class
      end
    end

    def column_family(name)
      self.column_family_name = name.to_s
      c = Cassequence.find_or_create_column_family(self.column_family_name)
    end
  end
  
  module InstanceMethods

    attr_accessor :raw

    def initialize(raw_in)
      self.raw = raw_in
    end

    def convert_to_default(key)
      begin
        result = JSON.parse(@raw)[key.to_s] rescue nil
        if result
          if const = self.class.default_types[key.to_sym]
            const.from_string(result) rescue result
          else
            result
          end
        else
          nil
        end
      rescue Exception => e
        nil
      end
    end

    def method_missing(meth, *args, &block)
      result = convert_to_default(key)
      # result = JSON.parse(@raw)[meth.to_s] rescue nil
      if result
        result
      else
        super # needs this
      end
    end
  end
  
  def self.included(receiver)
    receiver.extend         ClassMethods
    receiver.send :include, InstanceMethods
  end

end