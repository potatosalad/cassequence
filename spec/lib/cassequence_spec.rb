require 'spec_helper'

describe Cassequence do
  after :each do
    Cassequence.config = nil
  end
  
  it 'should create a config if one doesnt already exist' do
    Cassequence.config.class.should == Cassequence::Config
  end

  it 'should give back an existing config if one already exists' do
    conf = Cassequence.config
    Cassequence.config.should == conf
  end

  it 'should assign a new config if one is given' do
    conf = Cassequence::Config.new
    Cassequence.config = conf
    Cassequence.config.should == conf
  end

  it 'should raise an error if you attempt to assign something that is not a config' do
    lambda { Cassequence.config = 1 }.should raise_error
  end

  it 'should get a client instance if configured correctly' do
    Cassequence.configure do |config|
      config.key_space = 'Stats'
    end
    Cassequence.client(true)
    Cassequence.client.class.should == Cassandra
    Cassequence.client.keyspace.should == 'Stats'
    Cassequence.client.servers.should == ["127.0.0.1:9160"]
  end

  it 'should raise an error to get a client if its missing config options' do
    lambda { Cassequence.client }.should raise_error
  end

  it 'should pass find or create right on through' do
    Cassequence.configure do |config|
      config.key_space = 'Stats'
    end
    config = Cassequence.config
    config.should_receive(:find_or_create_column_family).with('dude').once
    Cassequence.find_or_create_column_family('dude')
  end

  it 'can set up config data in a block' do
    Cassequence.configure do |config|
      config.key_space = 'Stats'
      config.host = 'HAY DUDE'
      config.port = 1000000000
    end

    conf = Cassequence.config
    conf.host.should == 'HAY DUDE'
    conf.port.should == 1000000000
    conf.key_space.should == 'Stats'
  end
  
end