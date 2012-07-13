module Cassequence::Column
  module ClassMethods

    attr_accessor :column_family

    def where(hash)
      raise "Need :key in hash" unless hash[:key]
      result = Cassequence.client.get(self.column_family, hash.delete(:key).to_s, hash)
      result.values.map { |json|  self.class.new(raw: json)}
    end
    
    def column_family(name)
      puts "COLUMNFAMILY: #{name}"
      self.column_family = name.to_s
      Cassequence.find_or_create_column_family(self.column_family)
    end
  end
  
  module InstanceMethods

    attr_accessor :raw

    def method_missing(meth, *args, &block)
      result = JSON.parse(@raw)[meth.to_s]
      if result
        result
      else
        super # You *must* call super if you don't handle the
              # method, otherwise you'll mess up Ruby's method
              # lookup.
      end
    end
  end
  
  def self.included(receiver)
    receiver.extend         ClassMethods
    receiver.send :include, InstanceMethods
  end

end



