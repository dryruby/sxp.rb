require File.join(File.dirname(__FILE__), 'spec_helper')

describe SXP::Reader do
  it "should read '.' as a symbol" do
    SXP.read('.').should == :'.'
  end

  it "should read '\\' as a symbol" do
    SXP.read('\\').should == :'\\'
  end
end
