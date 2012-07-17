require 'spec_helper'

describe Integer do
  it 'should raise an error if it isnt an Integer type value' do
    lambda { Integer.from_string(' o geeze') }.should raise_error
    lambda { Integer.from_string(true) }.should raise_error
  end

  it 'should not raise an error if it is given the correct data' do
    Integer.from_string('1').should == 1
    Integer.from_string('0123').should == 123
  end

end