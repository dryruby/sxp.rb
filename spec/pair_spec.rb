require File.join(File.dirname(__FILE__), 'spec_helper')
require 'sxp/pair'

describe SXP::Pair, " when created empty" do
  subject {SXP::Pair.new}

  it "should not be nil" do
    is_expected.not_to be_nil
  end

  it "should be empty" do
    is_expected.to be_empty
  end

  it "should look like '(nil)'" do
    expect(subject.inspect).to eq '(nil)'
  end
end

describe SXP::Pair, " when created with a head" do
  subject {SXP::Pair.new(123, nil)}

  it "should not be empty" do
    is_expected.not_to be_empty
  end

  it "should have a head" do
    expect(subject.head).not_to be_nil
  end

  it "should not have a tail" do
    expect(subject.tail).to be_nil
  end

  it "should look like '(123)'" do
    expect(subject.inspect).to eq '(123)'
  end
end

describe SXP::Pair, " when created with a head and tail" do
  subject {SXP::Pair.new(123, 456)}

  it "should not be empty" do
    is_expected.not_to be_empty
  end

  it "should have a head" do
    expect(subject.head).not_to be_nil
  end

  it "should have a tail" do
    expect(subject.tail).not_to be_nil
  end

  it "should look like '(123 . 456)'" do
    expect(subject.inspect).to eq '(123 . 456)'
  end
end
