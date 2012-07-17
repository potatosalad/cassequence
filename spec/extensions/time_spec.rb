require 'spec_helper'

describe Time do
  it 'should raise an error if it isnt an Time type value' do
    lambda { Time.from_string(' o geeze') }.should raise_error
    lambda { Time.from_string(true) }.should raise_error
  end

  it 'should not raise an error if it is given the correct data' do
    Time.from_string('0').to_s.should == '1969-12-31 17:00:00 -0700'
    Time.from_string('0123').to_s.should == '1969-12-31 17:02:03 -0700'
  end

end