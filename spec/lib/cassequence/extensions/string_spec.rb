require 'spec_helper'

describe String do
  it 'should be able to turn almost anyting into a string' do
    String.from_string('1').should == '1'
    String.from_string(true).should == 'true'
    String.from_string(1.23).should == '1.23'
  end
end