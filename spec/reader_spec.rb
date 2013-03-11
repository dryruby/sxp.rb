require File.join(File.dirname(__FILE__), 'spec_helper')

describe SXP::Reader do
  context "when reading empty input" do
    it "raises an error" do
      lambda { read('') }.should raise_error(SXP::Reader::Error)
      lambda { read(' ') }.should raise_error(SXP::Reader::Error)
      lambda { read('#!/usr/bin/env sxp2json') }.should raise_error(SXP::Reader::Error)
    end
  end

  context "when reading shebang scripts" do
    it "ignores shebang lines" do
      read_all("#!/usr/bin/env sxp2json\n(1 2 3)\n").should == [[1, 2, 3]]
    end
  end

  context "when reading valid symbols" do
    it "reads ':' as a symbol" do
      read(':').should == :':'
    end

    it "reads '.' as a symbol" do
      read('.').should == :'.'
    end

    it "reads '\\' as a symbol" do
      read('\\').should == :'\\'
    end
  end

  context "when reading lists" do
    it "reads '()' as an empty list" do
      read('()').should == []
    end

    it "reads '[]' as an empty list" do
      read('[]').should == []
    end

    it "reads '[] 1' as an empty list" do
      read('[] 1').should == []
    end

    it "reads '(1 2 3)' as a list" do
      read('(1 2 3)').should == [1, 2, 3]
    end

    it "reads '(1 2 3) 4' as a list" do
      read('(1 2 3) 4').should == [1, 2, 3]
    end

    it "reads '[1 2 3]' as a list" do
      read('[1 2 3]').should == [1, 2, 3]
    end
  end

  context "when reading invalid input" do
    it "raises an error on '(1'" do
      lambda { read_all('(1') }.should raise_error(SXP::Reader::Error)
    end

    it "raises an error on '[1'" do
      lambda { read_all('[1') }.should raise_error(SXP::Reader::Error)
    end

    it "raises an error on '1)'" do
      lambda { read_all('1)') }.should raise_error(SXP::Reader::Error)
    end

    it "raises an error on '1]'" do
      lambda { read_all('1]') }.should raise_error(SXP::Reader::Error)
    end

    it "raises an error on '(1]'" do
      lambda { read_all('(1]') }.should raise_error(SXP::Reader::Error) # FIXME
    end

    it "raises an error on '[1)'" do
      lambda { read_all('[1)') }.should raise_error(SXP::Reader::Error) # FIXME
    end
  end

  def read(input, options = {})
    SXP.read(input.freeze, options)
  end

  def read_all(input, options = {})
    SXP.read_all(input.freeze, options)
  end
end
