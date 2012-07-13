module Cassequence::Column
  module ClassMethods

    attr_accessor :column_family_name

    def where(hash)
      Cassequence::Criteria.new(hash, self)
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

    def method_missing(meth, *args, &block)
      result = JSON.parse(@raw)[meth.to_s] rescue nil
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