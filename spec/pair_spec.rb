require 'sxp/pair'

describe SXP::Pair, " when created empty" do
  before :each do
    @pair = SXP::Pair.new
  end

  it "should not be nil" do
    @pair.should_not be_nil
  end

  it "should be empty" do
    @pair.should be_empty
  end

  it "should look like '(nil)'" do
    @pair.inspect.should == '(nil)'
  end
end

describe SXP::Pair, " when created with a head" do
  before :each do
    @pair = SXP::Pair.new(123, nil)
  end

  it "should not be empty" do
    @pair.should_not be_empty
  end

  it "should have a head" do
    @pair.head.should_not be_nil
  end

  it "should not have a tail" do
    @pair.tail.should be_nil
  end

  it "should look like '(123)'" do
    @pair.inspect.should == '(123)'
  end
end

describe SXP::Pair, " when created with a head and tail" do
  before :each do
    @pair = SXP::Pair.new(123, 456)
  end

  it "should not be empty" do
    @pair.should_not be_empty
  end

  it "should have a head" do
    @pair.head.should_not be_nil
  end

  it "should have a tail" do
    @pair.tail.should_not be_nil
  end

  it "should look like '(123 . 456)'" do
    @pair.inspect.should == '(123 . 456)'
  end
end
