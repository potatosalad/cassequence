require 'spec_helper'

describe Float do
  it 'should raise an error if it isnt an Float type value' do
    lambda { Float.from_string(' o geeze') }.should raise_error
    lambda { Float.from_string(true) }.should raise_error
  end

  it 'should not raise an error if it is given the correct data' do
    Float.from_string('1.23').should == 1.23
    Float.from_string('0.0').should == 0.0
  end

end