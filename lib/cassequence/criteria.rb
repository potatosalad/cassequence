module Cassequence

  class Criteria

    attr_accessor :query_hash
    attr_accessor :klass
    attr_accessor :result

    def initialize(hash, kla)
      self.query_hash = hash
      self.klass = kla
    end

    def where(hash)
      self.query_hash.merge! hash
      self
    end
    
    def get_results
      validate_hash
      self.result = Cassequence.client.get(self.klass.column_family_name, self.query_hash.delete(:key).to_s, self.query_hash)
      self.result.values.map! { |json|  self.klass.new(json)}
    end
    alias :all :get_results

    def each(&proc)
      get_results
      self.result.each &proc
    end

    def first
      get_results
      self.result.first
    end

    def last
      get_results
      self.result.last
    end

    def limit(number)
      self.query_hash[:count] = number
      self
    end

    def count
      get_results
      self.result.count
    end
    
  private

    def validate_hash
      validate_hash_key
      validate_hash_nothing_crazy
      validate_hash_order
      change_time_to_byte
    end

    def validate_hash_key
      raise "I need a :key" unless self.query_hash.include? :key
    end

    def validate_hash_nothing_crazy
      if remains = self.query_hash.keys - [:count, :start, :finish, :reversed]
        raise "Invalid Arguements #{remains}" 
      end
    end

    def validate_hash_order
      if self.query_hash[:reversed]
        if self.query_hash[:start] and self.query_hash[:finish]
          if self.query_hash[:start] < self.query_hash[:finish]
            reverse_times
          end
        end
      else
        if self.query_hash[:start] and self.query_hash[:finish]
          if self.query_hash[:start] > self.query_hash[:finish]
            reverse_times
          end
        end
      end
    end

    def reverse_times
      tmp = self.query_hash[:start]
      self.query_hash[:start] = self.query_hash[:finish]
      self.query_hash[:finish] = self.query_hash[:start]
    end

    def change_time_to_byte
      self.query_hash[:start] = to_byte(self.query_hash[:start]) if self.query_hash[:start]
      self.query_hash[:finish] = to_byte(self.query_hash[:finish]) if self.query_hash[:finish]
    end

    def to_byte(time)
      time = (time.to_f*1000).to_i
      [time >> 32, time].pack('NN')  
    end

  end

end