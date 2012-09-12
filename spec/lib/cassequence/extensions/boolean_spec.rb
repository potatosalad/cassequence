require 'spec_helper'

describe Boolean do
  it 'should raise an error if it isnt an boolean type value' do
    lambda { Boolean.from_string(' o geeze') }.should raise_error
    lambda { Boolean.from_string(123) }.should raise_error
  end

  it 'should not raise an error if it is given the correct data' do
    Boolean.from_string('true').should == true
    Boolean.from_string('false').should == false
  end

end