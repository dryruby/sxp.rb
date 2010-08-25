require File.join(File.dirname(__FILE__), 'spec_helper')

describe SXP::Reader::CommonLisp do
  context "when reading empty input" do
    it "raises an error" do
      lambda { read('') }.should raise_error(SXP::Reader::Error)
      lambda { read(' ') }.should raise_error(SXP::Reader::Error)
    end
  end

  context "when reading symbols" do
    symbols = %w(lambda)
    symbols.each do |symbol|
      it "reads `#{symbol}` as a symbol" do
        read(%Q(#{symbol})).should == symbol.to_sym
      end
    end

    symbols += ['foo bar']
    symbols.each do |symbol|
      it "reads `|#{symbol}|` as a symbol" do
        read(%Q(|#{symbol}|)).should == symbol.to_sym
      end
    end
  end

  context "when reading characters" do
    it "reads `#\\a` as a character" do
      read(%q(#\a)).should == "a"
    end

    it "reads `#\\newline` as a character" do
      read(%q(#\newline)).should == "\n"
    end

    it "reads `#\\space` as a character" do
      read(%q(#\space)).should == ' '
    end
  end

  context "when reading strings" do
    it "reads `\"foo\"` as a string" do
      read(%q("foo")).should == "foo"
    end
  end

  context "when reading escaped strings" do
    # TODO
  end

  context "when reading integers in decimal form" do
    it "reads `123` as an integer" do
      read(%q(123)).should == 123
    end
  end

  context "when reading integers in hexadecimal form" do
    %w(#xFF #XFF #xff #XFF).each do |input|
      it "reads `#{input}` as an integer" do
        read(input).should == 0xFF
      end
    end
  end

  context "when reading lists" do
    it "reads `()` as an empty list" do
      read(%q(())).should == [] # FIXME
    end

    it "reads `(1 2 3)` as a list" do
      read(%((1 2 3))).should == [1, 2, 3]
    end
  end

  context "when reading vectors" do
    it "reads `#()` as an empty vector" do
      read(%(#())).should == []
    end

    it "reads `#(1 2 3)` as a vector" do
      read(%q(#(1 2 3))).should == [1, 2, 3]
    end
  end

  context "when reading functions" do
    %w(fn).each do |input|
      it "reads `#'#{input}` as a function object" do
        read(%Q(#'#{input})).should == [:function, output = input.to_sym]
      end
    end

    {%q((lambda (x) x)) => [:lambda, [:x], :x]}.each do |input, output|
      it "reads `#'#{input}` as a function object" do
        read(%Q(#'#{input})).should == [:function, output]
      end
    end
  end

  context "when reading quotations" do
    {%q((lambda (x) x)) => [:lambda, [:x], :x]}.each do |input, output|
      it "reads `'#{input}` as a quotation" do
        read(%Q('#{input})).should == [:quote, output]
      end
    end
  end

  context "when reading comments" do
    it "reads `() ; a comment` as a list" do
      read_all(%q(() ; a comment)).should == [[]]
    end
  end

  def read(input, options = {})
    SXP::Reader::CommonLisp.new(input.freeze, options.freeze).read
  end

  def read_all(input, options = {})
    SXP::Reader::CommonLisp.new(input.freeze, options.freeze).read_all
  end
end
