require 'spec_helper'

describe Cassequence::Config do

  describe 'client' do

    it 'should raise an error unless it has what it needs' do
      conf = Cassequence::Config.new
      lambda { conf.client }.should raise_error
    end

    it 'should keyspace if one does not exist' do
      conf = Cassequence::Config.new
      conf.key_space = 'notreal'
      lambda { conf.client }.should raise_error
    end

    it 'should return a cassandra client if all goes well' do
      conf = Cassequence::Config.new
      conf.key_space = 'Stats'
      conf.client.class.should == Cassandra
    end

  end

  describe 'find_or_create_column_family' do
    before :all do
      @conf = Cassequence::Config.new
      @conf.key_space = 'Stats'
    end

    after :all do
      @conf.client.drop_column_family 'my_guy'
    end

    it 'should create column family and set the comparator to date_type' do
      @conf.find_or_create_column_family('my_guy').should == true
      cf = @conf.client.column_families['my_guy']
      cf.comparator_type.should == 'org.apache.cassandra.db.marshal.DateType'
    end

    it 'should set the comparator to date_type if the family already exists' do
      @conf.find_or_create_column_family('my_guy')
      cf = @conf.client.column_families['my_guy']
      cf.comparator_type.should == 'org.apache.cassandra.db.marshal.DateType'
    end
    
  end

end