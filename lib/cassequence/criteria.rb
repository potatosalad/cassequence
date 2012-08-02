require 'oj'
require 'multi_json'

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
        self.result = Cassequence.client.get(self.klass.column_family_name, key, self.query_hash)
        self.result = self.result.values.map! { |json|  self.klass.new(json)}
      end
      self.result
    end
    alias :all :get_results

    def get_raw
      unless self.raw_result      
        validate_hash
        self.raw_result = Cassequence.client.get(self.klass.column_family_name, key, self.query_hash)
        self.raw_result = self.raw_result.values.map { |json|  MultiJson.load(json) }
      end
      self.raw_result
    end
    alias :raw :get_raw

    def reduce(arr, interval = 900)
      raise 'Arguements must be reduce(Array, Integer)' unless arr.is_a?(Array) and interval.is_a?(Integer)
      aggrogate = {}
      count = {}
      set_up_hash = arr.inject({}) { |h, ele| h[ele.to_s] = 0.0; h}
      raw.each do |ele|
        key = middle_of(ele['time'], interval).to_s
        aggrogate[key] ||= set_up_hash.dup
        count[key] ||= 0
        count[key] += 1
        arr.each { |guy| aggrogate[key][guy.to_s] += ele[guy.to_s]}
      end
      result = []
      aggrogate.each do |key, value|
        c = count[key]
        arr.each { |guy| value[guy.to_s] = value[guy.to_s] / c }
        result << ({'time' => key.to_i}.merge value)
      end
      result
    end

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

    def min(symb)
      get_results
      self.result.min { |a,b| a.send(symb) <=> b.send(symb) }
    end

    def avg(input)
      get_results
      if input.class == Array
        average_these(input)
      elsif input.class == Symbol
        average_one(input)
      else
        raise 'I need a Symbol or an Array'    
      end
    end

    def max(symb)
      get_results
      self.result.max { |a,b| a.send(symb) <=> b.send(symb) }
    end

    def count
      get_results
      self.result.count
    end

    def to_a
      get_results
      self.result
    end
    
    def key
      @key ||= (self.query_hash[:key]) ? self.query_hash.delete(:key) : nil
    end

    def key=(string)
      @key = string
    end

  private

    def average_these(arr)
      # hash = arr.inject({}) {|hash, key| hash[key.to_sym] = 0.0; hash}
      avg = result.inject(arr.inject({}) {|hash, key| hash[key.to_sym] = 0.0; hash}) do |hash, value|
        data = MultiJson.load(value.raw)
        arr.each {|key| hash[key.to_sym] += data[key.to_s].to_f}
        hash
      end
      c = result.count
      arr.each {|key| avg[key.to_sym] = avg[key.to_sym] / c }
      avg
    end

    def average_one(symb)
      avg = result.inject(0.0) { |float, element| float + MultiJson.load(element.raw)[symb.to_s]}
      avg / result.count
    end

    def validate_hash
      validate_hash_key
      validate_hash_nothing_crazy
      validate_hash_types
      fix_times_order
      change_time_to_byte
    end

    def validate_hash_key
      raise "I need a :key" unless key
    end

    def validate_hash_nothing_crazy
      remains = self.query_hash.keys - [:count, :start, :finish, :reversed, :key]
      unless remains.empty?
        raise "Invalid Arguements #{remains}" 
      end
    end

    def validate_hash_types
      raise ":key needs to be a String object" unless key.is_a?(String)
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

    def middle_of(num, interval = 900)
      num - (num % interval) + (interval / 2)
    end

  end

end