require 'spec_helper'

def to_byte(time)
  time = (time.to_f*1000).to_i
  [time >> 32, time].pack('NN')  
end

Cassequence.configure do |config|
  config.host = '127.0.0.1'
  config.port = 9160
  config.key_space = 'Stats'
end

class SimpleClass
  include Cassequence::Column

  column_family :Stats

  field :time, type: Time
  field :num, type: Integer
  field :precise_num, type: Float
  field :boo, type: Boolean
  field :string, type: String
  field :whatever

end

describe Cassequence::Criteria do

  # after :all do
  #   Cassequence.config = nil
  # end

  describe 'initialize' do
    it 'will only initialize with a hash and a class passed to it' do
      crit = Cassequence::Criteria.new({}, SimpleClass)
    end

    it 'raises an error if they are not of the correct class' do
      lambda { Cassequence::Criteria.new() }.should raise_error
      lambda { Cassequence::Criteria.new('thing', 'bad') }.should raise_error
      lambda { Cassequence::Criteria.new(1,2) }.should raise_error
      lambda { Cassequence::Criteria.new({hahs: 'value'}, 'string') }.should raise_error
      lambda { Cassequence::Criteria.new({:gungan => 'dumb'}, SimpleClass) }.should_not raise_error
    end
  end

  describe 'where' do
    it 'takes only a hash' do
      lambda { SimpleClass.where('not a hash') }.should raise_error
    end

    it 'merges the where hashes it is given' do
      cri = SimpleClass.where(key: 'apple').where(count: 10)
      cri.query_hash.should == {:key=>"apple", :count=>10}
    end


    it 'merges the new on top of the old' do
      cri = SimpleClass.where(key: 'apple', count: 100000).where(count: 10)
      cri.query_hash.should == {:key=>"apple", :count=>10}
    end

  end

  describe 'get_results' do
    
    before :all do
      Cassequence.config.key_space = 'Stats'
      cli = Cassequence.client
      cli.insert(:Stats, 'apple', { to_byte(Time.now) => { 'time' => Time.now.to_i, 'num' => 1, 'precise_num' => 2.34, 'boo' => true, 'string' => 'hi'}.to_json }, ttl: 60)
      cli.insert(:Stats, 'apple', { to_byte(Time.now) => { 'time' => Time.now.to_i, 'num' => 2, 'precise_num' => 3.34, 'boo' => true, 'string' => 'hi how'}.to_json }, ttl: 60)
      cli.insert(:Stats, 'apple', { to_byte(Time.now) => { 'time' => Time.now.to_i, 'num' => 3, 'precise_num' => 4.34, 'boo' => false, 'string' => 'hi how are'}.to_json }, ttl: 60)
      cli.insert(:Stats, 'apple', { to_byte(Time.now) => { 'time' => Time.now.to_i, 'num' => 4, 'precise_num' => 5.34, 'boo' => false, 'string' => 'hi how are you?'}.to_json }, ttl: 60)
    end

    after :all do
      Cassequence.client.truncate! 'Stats'
    end

    it 'should call validate_hash before trying to use' do
      cri = SimpleClass.where(key: 'apple', count: 10)
      cri.should_receive(:validate_hash).once
      cri.get_results
    end

    it 'should be able to get the sequence elements' do
      cri = SimpleClass.where(key: 'apple', count: 10)
      result = cri.get_results
      result.length.should > 0
    end

    it 'should build results of the class it was given' do
      cri = SimpleClass.where(key: 'apple')
      result = cri.get_results
      result.each {|res| res.class.should == SimpleClass}
    end

    it 'should not do anything if it already has results' do
      cri = SimpleClass.where(key: 'apple')
      cri.get_results
      cri.should_receive(:validate_hash).exactly(0).times
      cri.get_results
    end

  end

  describe 'pass_through' do
    before :all do
      Cassequence.config.key_space = 'Stats'
      cli = Cassequence.client
      cli.insert(:Stats, 'apple', { to_byte(Time.now) => { 'time' => Time.now.to_i, 'num' => 1, 'precise_num' => 2.34, 'boo' => true, 'string' => 'hi'}.to_json }, ttl: 60)
      cli.insert(:Stats, 'apple', { to_byte(Time.now) => { 'time' => Time.now.to_i, 'num' => 2, 'precise_num' => 3.34, 'boo' => true, 'string' => 'hi how'}.to_json }, ttl: 60)
      cli.insert(:Stats, 'apple', { to_byte(Time.now) => { 'time' => Time.now.to_i, 'num' => 3, 'precise_num' => 4.34, 'boo' => false, 'string' => 'hi how are'}.to_json }, ttl: 60)
      cli.insert(:Stats, 'apple', { to_byte(Time.now) => { 'time' => Time.now.to_i, 'num' => 4, 'precise_num' => 5.34, 'boo' => false, 'string' => 'hi how are you?'}.to_json }, ttl: 60)
      @cri = SimpleClass.where(key: 'apple')
    end

    after :all do
      Cassequence.client.truncate! 'Stats'
    end


    it 'should pass the each right through to the array' do
      numbs = []
      @cri.each do |thing|
        numbs << thing.num
      end
      numbs.length.should > 0 
    end

    it 'should get the first element in the array' do
      @cri.first.should == @cri.result.first
    end

    it 'should get the last element in the array' do
      @cri.last.should == @cri.result.last
    end

    it 'should pass [] through to the array' do
      @cri[1].should == @cri.result[1]
      @cri[2].should == @cri.result[2]
    end

    it 'should get a count of how many there are in the result set' do
      @cri.count.should > 0
    end

    it 'should return the results with a to_a' do
      @cri.to_a.should == @cri.result
    end

  end

  describe 'limit' do
    it 'should append the limit to the back of the hash' do
      cri = SimpleClass.where(key: 'apple').limit(10)
      cri.query_hash.should == {:key=>"apple", :count=>10}
    end

    it 'should overwrite the current limit' do
      cri = SimpleClass.where(key: 'apple').limit(10021).limit(10)
      cri.query_hash.should == {:key=>"apple", :count=>10}
    end

  end

  describe 'validate_hash_key' do
    it 'should raise if there is no key' do
      cri = SimpleClass.where(start: Time.now)
      lambda { cri.all }.should raise_error(RuntimeError, 'I need a :key')
    end

    it 'shouldnt raise if there is a key' do
      cri = SimpleClass.where(start: Time.now, :key => 'farters')
      cri.all
    end

  end

  describe 'validate_hash_nothing_crazy' do
    it 'should raise an error if there is an unexpected key' do
      cri = SimpleClass.where(nogood: 'ughtoh', key: 'keey')
      lambda { cri.all }.should raise_error(RuntimeError, 'Invalid Arguements [:nogood]')
      cri.where(start: Time.now, :finish => Time.now + 100, count: 1000, :cpu => 12)
      lambda { cri.all }.should raise_error(RuntimeError, 'Invalid Arguements [:nogood, :cpu]')
    end

    it 'shouldnt raise an error if the keys all match' do
      SimpleClass.where(start: Time.now, :finish => Time.now + 100, count: 100, key: 'cows').all
    end

  end

  describe 'validate_hash_types' do
    it 'should raise errors if the types are not correct' do
      lambda { SimpleClass.where(start: Time.now, :finish => Time.now + 100, count: 1000, key: 1).all }.should raise_error(RuntimeError, ':key needs to be a String object')
      lambda { SimpleClass.where(start: Time.now, :finish => Time.now + 100, count: '1000', key: 'key').all }.should raise_error(RuntimeError, ':count needs to be a Integer object')
      lambda { SimpleClass.where(start: 12342, :finish => Time.now + 100, count: 1000, key: 'key').all }.should raise_error(RuntimeError, ':start needs to be a Time object')
      lambda { SimpleClass.where(start: Time.now - 1, :finish => 1.23, count: 1000, key: 'key').all }.should raise_error(RuntimeError, ':finish needs to be a Time object')
      lambda { SimpleClass.where(start: Time.now - 1, :finish => Time.now, reversed: 'not bool', count: 1000, key: 'key').all }.should raise_error(RuntimeError, ':reversed needs to be a Boolean object')
    end
  end

  describe 'fix_hash_order' do
    it 'should make sure the time stamps are in the correct order' do
      first = Time.now - 1000
      last = Time.now
      cri = SimpleClass.where(start: first, finish: last)
      cri.send :fix_times_order
      cri.query_hash.should == {start: first, finish: last}
    end

    it 'should make sure the time stamps are in the correct order reversed' do
      first = Time.now - 1000
      last = Time.now
      cri = SimpleClass.where(start: first, finish: last, reversed: true)
      cri.send :fix_times_order
      cri.query_hash.should == {start: last, finish: first, reversed: true}
    end

    it 'will re order the timestamps if they are in the wrong order' do
      first = Time.now - 1000
      last = Time.now
      cri = SimpleClass.where(start: last, finish: first)
      cri.send :fix_times_order
      cri.query_hash.should == {start: first, finish: last}
    end

  end

  describe 'change_time_to_byte' do
    it 'changes times to a byte string if they exist' do
      first = Time.now - 1000
      last = Time.now
      cri = SimpleClass.where(start: last, finish: first)
      cri.send :change_time_to_byte
      cri.query_hash[:start].is_a?(String).should == true
      cri.query_hash[:finish].is_a?(String).should == true
    end

  end

end