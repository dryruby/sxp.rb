require File.join(File.dirname(__FILE__), 'spec_helper')

describe SXP::Reader do
  context "when reading empty input" do
    it "should complain" do
      lambda { read('') }.should raise_error(Reader::Error)
      lambda { read(' ') }.should raise_error(Reader::Error)
      lambda { read('#!/usr/bin/env sxp2json') }.should raise_error(Reader::Error)
    end
  end

  context "when reading shebang scripts" do
    it "should not choke on shebang lines" do
      read_all("#!/usr/bin/env sxp2json\n(1 2 3)\n").should == [[1, 2, 3]]
    end
  end

  context "when reading valid symbols" do
    it "should read ':' as a symbol" do
      read(':').should == :':'
    end

    it "should read '.' as a symbol" do
      read('.').should == :'.'
    end

    it "should read '\\' as a symbol" do
      read('\\').should == :'\\'
    end
  end

  context "when reading lists" do
    it "should read '()' as an empty list" do
      read('()').should == []
    end

    it "should read '[]' as an empty list" do
      read('[]').should == []
    end

    it "should read '(1 2 3)' as a list" do
      read('(1 2 3)').should == [1, 2, 3]
    end

    it "should read '[1 2 3]' as a list" do
      read('[1 2 3]').should == [1, 2, 3]
    end
  end

  context "when reading invalid input" do
    it "should not read '(1'" do
      lambda { read_all('(1') }.should raise_error(Reader::Error)
    end

    it "should not read '[1'" do
      lambda { read_all('[1') }.should raise_error(Reader::Error)
    end

    it "should not read '1)'" do
      lambda { read_all('1)') }.should raise_error(Reader::Error)
    end

    it "should not read '1]'" do
      lambda { read_all('1]') }.should raise_error(Reader::Error)
    end

    it "should not read '(1]'" do
      lambda { read_all('(1]') }.should raise_error(Reader::Error) # FIXME
    end

    it "should not read '[1)'" do
      lambda { read_all('[1)') }.should raise_error(Reader::Error) # FIXME
    end
  end

  def read(input, options = {})
    SXP.read(input, options)
  end

  def read_all(input, options = {})
    SXP.read_all(input, options)
  end
end
