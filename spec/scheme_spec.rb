require File.join(File.dirname(__FILE__), 'spec_helper')

describe SXP::Reader::Scheme do
  context "when reading empty input" do
    it "raises an error" do
      lambda { read('') }.should raise_error(SXP::Reader::Error)
      lambda { read(' ') }.should raise_error(SXP::Reader::Error)
    end
  end

  context "when reading symbols" do
    %w(lambda list->vector + <=? q soup V17a a34kTMNs the-word-recursion-has-many-meanings).each do |symbol|
      it "reads '#{symbol}' as a symbol" do
        read(%Q(#{symbol})).should == symbol.to_sym
      end
    end
  end

  context "when reading strings" do
    it "reads '\"foo\"' as a string" do
      read(%q("foo")).should == "foo"
    end
  end

  context "when reading characters" do
    {
      %q(#\a)       => "a",
      %q(#\A)       => "A",
      %q(#\C)       => "C",
      %q(#\ )       => " ",
      %q(#\space)   => " ",
      %q(#\newline) => "\n",
    }.each do |input, output|
      it "reads '#{input}' as a character" do
        read(input).should == output
      end
    end
  end

  context "when reading integers in decimal form" do
    it "reads '123' as an integer" do
      read(%q(123)).should   == 123
    end

    it "reads '#d123' as an integer" do
      read(%q(#d123)).should == 123
    end

    it "reads '#D123' as an integer" do
      read(%q(#D123)).should == 123
    end
  end

  context "when reading integers in binary form" do
    it "reads '#b1010' as an integer" do
      read(%q(#b1010)).should == 0b1010
    end

    it "reads '#B1010' as an integer" do
      read(%q(#B1010)).should == 0b1010
    end
  end

  context "when reading integers in octal form" do
    it "reads '#o755' as an integer" do
      read(%q(#o755)).should == 0755
    end

    it "reads '#O755' as an integer" do
      read(%q(#O755)).should == 0755
    end
  end

  context "when reading integers in hexadecimal form" do
    it "reads '#xFF' as an integer" do
      read(%q(#xFF)).should == 0xFF
    end

    it "reads '#XFF' as an integer" do
      read(%q(#XFF)).should == 0xFF
    end
  end

  context "when reading floats" do
    it "reads '3.1415' as a float" do
      read(%q(3.1415)).should == 3.1415
    end
  end

  context "when reading fractions" do
    it "reads '1/2' as a rational" do
      read(%q(1/2)).should == Rational(1, 2)
    end
  end

  context "when reading booleans" do
    it "reads '#t' as true" do
      read(%q(#t)).should == true
    end

    it "reads '#T' as true" do
      read(%q(#T)).should == true
    end

    it "reads '#f' as false" do
      read(%q(#f)).should == false
    end

    it "reads '#F' as false" do
      read(%q(#F)).should == false
    end
  end

  context "when reading lists" do
    it "reads '()' as an empty list" do
      read(%q(())).should == [] # FIXME
    end

    it "reads '(1 2 3)' as a list" do
      read(%((1 2 3))).should == [1, 2, 3]
    end
  end

  context "when reading vectors", :pending => "Support for vectors" do
    it "reads '#()' as an empty vector" do
      read(%(#())).should == []
    end

    it "reads '#(1 2 3)' as a vector" do
      read(%q(#(1 2 3))).should == [1, 2, 3]
    end
  end

  context "when reading comments" do
    it "reads '() ; a comment' as a list" do
      read_all('() ; a comment').should == [[]]
    end
  end

  def read(input, options = {})
    SXP::Reader::Scheme.new(input.freeze, options.freeze).read
  end

  def read_all(input, options = {})
    SXP::Reader::Scheme.new(input.freeze, options.freeze).read_all
  end
end
