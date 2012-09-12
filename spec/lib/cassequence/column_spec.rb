require 'spec_helper'

Cassequence.configure do |config|
  config.host = '127.0.0.1'
  config.port = 9160
  config.key_space = 'Stats'
end

class SampleClass
  include Cassequence::Column

  column_family :component_stats

  field :time, type: Time
  field :num, type: Integer
  field :precise_num, type: Float
  field :boo, type: Boolean
  field :string, type: String
  field :whatever

end

  
describe Cassequence::Column do

  describe 'where' do
    it 'should give the inheriting class a where function' do
      SampleClass.respond_to?(:where).should == true
    end

    it 'where should return a criteria with data' do
      result = SampleClass.where(key: 'something')
      result.class.should == Cassequence::Criteria
    end

  end

  describe 'insert' do

    before :all do
      Cassequence.config.key_space = 'Stats'
    end

    after :all do
      Cassequence.client.truncate! 'component_stats'
    end

    it 'should insert data' do
      SampleClass.insert('abc', {time: Time.now, num: 1, precise_num: 1.2, boo: true, string: 'hi', whatever: 'thing'})
      SampleClass.where(key: 'abc').count.should == 1
    end

    it 'should raise an error if it is missing they key' do
      lambda { SampleClass.insert({}) }.should raise_error
    end

    it 'should be able to accept options' do
      SampleClass.insert('abc', {time: Time.now, num: 1, precise_num: 1.2, boo: true, string: 'hi', whatever: 'thing'}, ttl: 1).should == true
    end
  end

  describe 'field' do
    it 'should set a default_type on the class' do
      SampleClass.default_type.class.should == Hash
    end

    it 'should populate the default type for the field' do
      SampleClass.default_type.should == {:time=>Time, :num=>Integer, :precise_num=>Float, :boo=>Boolean, :string=>String}
    end
  end

  describe 'column_family' do

    it 'should set its column family' do
      SampleClass.column_family_name.should == 'component_stats'
    end

    it 'should call the Cassequence find_or_create_by' do
      Cassequence.should_receive(:find_or_create_column_family).with('cow_farts').once
      class Temp
        include Cassequence::Column
        column_family :cow_farts
      end
    end

  end

  describe 'convert_to_default' do
    
    it 'get defaults for all values that have defaults' do
      tim = Time.now.to_i
      test = SampleClass.new({:time => tim , :num => 1, :precise_num => 1.23, :boo => true, :string => 'foreals'}.to_json)
      test.convert_to_default('time').should == Time.at(tim)
      test.convert_to_default(:num).should == 1
      test.convert_to_default('precise_num').should == 1.23
      test.convert_to_default(:boo).should == true
      test.convert_to_default('string').should == 'foreals'
    end

    it 'leaves them as strings if no default value is given' do
      test = SampleClass.new({:whatever => 'this is a string'}.to_json)
      test.convert_to_default(:whatever).should == 'this is a string'
    end

    it 'leaves them as strings if it fails to convert' do
      test = SampleClass.new({:time => 'hay' , :num => "i", :precise_num => 'didnt', :boo => 'expect', :string => true}.to_json)
      test.convert_to_default('time').should == 'hay'
      test.convert_to_default(:num).should == 'i'
      test.convert_to_default('precise_num').should == 'didnt'
      test.convert_to_default(:boo).should == 'expect'
      test.convert_to_default('string').should == 'true'
    end

  end

  describe 'method_missing' do
    it 'should grab any data that is raw' do
      tim = Time.now.to_i
      test = SampleClass.new({:time => tim , :num => 1, :precise_num => 1.23, :boo => true, :string => 'foreals'}.to_json)
      test.time.should == Time.at(tim)
      test.num.should == 1
      test.precise_num.should == 1.23
      test.boo.should == true
      test.string.should == 'foreals'
    end

    it 'should raise a method missing if there is no data in the raw' do
      test = SampleClass.new({:string => 'foreals'}.to_json)
      lambda { test.cows }.should raise_error 
    end

    it 'should always return a result even if there is no default type' do
      tim = Time.now.to_i
      test = SampleClass.new({:time => tim , :num => 'threes', :precise_num => 1.23, :boo => true, :string => 'foreals', :whatever => 'this is a string'}.to_json)
      test.num.should == 'threes'
      test.whatever.should == 'this is a string'
    end

  end

end