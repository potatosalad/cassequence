
module Cassequence::Column
  module ClassMethods

    attr_accessor :column_family_name

    attr_accessor :default_types

    def insert(key, hash, options = {})
      Cassequence.client.insert(self.column_family_name, key, { to_byte(Time.now) => hash.to_json }, options)
      true
    end

    def where(hash)
      Cassequence::Criteria.new(hash, self)
    end
    
    def default_type
      self.default_types ||= {}
    end

    def field(key, options = {})
      if type = options[:type]
        default_type[key.to_sym] = type if type.class == Class
      end
    end

    def column_family(name)
      self.column_family_name = name.to_s
      c = Cassequence.find_or_create_column_family(self.column_family_name)
    end

    def to_byte(time)
      time = (time.to_f*1000).to_i
      [time >> 32, time].pack('NN')  
    end    
  end
  
  module InstanceMethods

    attr_accessor :raw

    def initialize(raw_in)
      self.raw = raw_in
    end

    def values
      JSON.parse(@raw)
    end

    def convert_to_default(key)
      begin
        result = values[key.to_s] rescue nil
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
      result = convert_to_default(meth.to_s)
      # result = JSON.parse(@raw)[meth.to_s] rescue nil
      unless result == nil
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