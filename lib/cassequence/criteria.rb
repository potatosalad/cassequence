module Cassequence

  class Criteria

    attr_accessor :query_hash
    attr_accessor :klass

    attr_accessor :result
    attr_accessor :raw_result

    def initialize(hash, kla)
      raise 'invalid type' unless hash.class == Hash and kla.class == Class
      self.query_hash = hash
      self.klass = kla
    end

    def where(hash)
      raise 'Invalid type' unless hash.class == Hash
      self.query_hash.merge! hash
      self
    end
    
    def get_results
      unless self.result
        validate_hash
        self.result = Cassequence.client.get(self.klass.column_family_name, self.query_hash.delete(:key).to_s, self.query_hash)
        self.result = self.result.values.map! { |json|  self.klass.new(json)}
      end
      self.result
    end
    alias :all :get_results

    def get_raw
      unless self.raw_result      
        validate_hash
        self.raw_result = Cassequence.client.get(self.klass.column_family_name, self.query_hash.delete(:key).to_s, self.query_hash)
        self.raw_result.values.map! { |json|  json }.to_json
      end
      self.raw_result
    end
    alias :raw :get_raw

    def each(&proc)
      get_results
      self.result.each &proc
    end

    def first
      get_results
      self.result.first
    end

    def [](num)
      get_results
      self.result[num]
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

    def to_a
      get_results
      self.result
    end
    
  private

    def validate_hash
      validate_hash_key
      validate_hash_nothing_crazy
      validate_hash_types
      fix_times_order
      change_time_to_byte
    end

    def validate_hash_key
      raise "I need a :key" unless self.query_hash.include? :key
    end

    def validate_hash_nothing_crazy
      remains = self.query_hash.keys - [:count, :start, :finish, :reversed, :key]
      unless remains.empty?
        raise "Invalid Arguements #{remains}" 
      end
    end

    def validate_hash_types
      raise ":key needs to be a String object" unless self.query_hash[:key].class == String
      (raise ":start needs to be a Time object" unless self.query_hash[:start].class == Time) if self.query_hash[:start]
      (raise ":finish needs to be a Time object" unless self.query_hash[:finish].class == Time) if self.query_hash[:finish]
      (raise ":reversed needs to be a Boolean object" unless self.query_hash[:reversed] == true or self.query_hash[:reversed] == false) if self.query_hash[:reversed]
      (raise ":count needs to be a Integer object" unless self.query_hash[:count].is_a?(Integer)) if self.query_hash[:count]
    end

    def fix_times_order
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
      self.query_hash[:finish] = tmp
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