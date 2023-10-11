require File.join(File.dirname(__FILE__), 'spec_helper')

describe SXP::Reader::CommonLisp do
  context "when reading invalid input" do
    it "raises an error when empty" do
      expect { read('') }.to raise_error(SXP::Reader::Error)
    end

    it "raises an error on blank" do
      expect { read(' ') }.to raise_error(SXP::Reader::Error)
    end

    it "raises an error on an illegal sharp sequence" do
      expect { read('#fx') }.to raise_error(SXP::Reader::Error, /invalid sharp-sign read/)
    end
  end

  context "when reading symbols" do
    symbols = %w(lambda)
    symbols.each do |symbol|
      it "reads `#{symbol}` as a symbol" do
        expect(read(%Q(#{symbol}))).to eq symbol.to_sym
      end
    end

    symbols += ['foo bar']
    symbols.each do |symbol|
      it "reads `|#{symbol}|` as a symbol" do
        expect(read(%Q(|#{symbol}|))).to eq symbol.to_sym
      end
    end

    it "reads `|\\backspace|` as a symbol" do
      expect(read(%Q(|\\backspace|))).to eq :backspace
    end
  end

  context "when reading escape sequences" do
    it "reads `#\a` as a character" do
      expect(read('#\a')).to eq 'a'
    end

    it "reads `#ab` as a single character" do
      expect(read('#\ab')).to eq 'a'
    end

    it "reads `# ` as a character" do
      expect(read('#\ ')).to eq ' '
    end

    SXP::Reader::CommonLisp::CHARACTERS.each do |escape, char|
      it "reads `#\\#{escape}` as a character" do
        expect(read('#\\' + escape)).to eq char
      end

      it "reads `#\\#{escape.upcase}` as a character" do
        expect(read('#\\' + escape.upcase)).to eq char
      end
    end
  end

  context "when reading strings" do
    it "reads `\"foo\"` as a string" do
      res = read(%q("foo"))
      expect(res).to eq "foo"
      expect(res.quote_style == :squote)
    end
  end

  context "when reading escaped strings" do
    # TODO
  end

  context "when reading integers" do
    {
      '#b1010' => 0b1010,
      '#B1010' => 0b1010,
      '#o755' => 0755,
      '#O755' => 0755,
      '123' => 123,
      '#xFF' => 0xFF,
      '#XFF' => 0xFF,
      '#xff' => 0xFF,
      '#Xff' => 0xFF,
    }.each_pair do |input, output|
      it "reads #{input} as an integer" do
        expect(read(input)).to eq output
      end
    end
  end

  context "when reading atoms" do
    {
      '.' => :".",
      't' => true,
      'T' => true,
      'nil' => nil,
      'NIL' => nil,
      '1/2' => Rational(1, 2),
      '1.0' => Float(1.0),
      "10" => Integer(10),
    }.each_pair do |input, output|
      it "reads #{input} as an atom" do
        expect(read(input)).to eq output
      end
    end
  end

  context "when reading lists" do
    it "reads `()` as an empty list" do
      expect(read(%q(()))).to eq [] # FIXME
    end

    it "reads `(1 2 3)` as a list" do
      expect(read(%((1 2 3)))).to eq [1, 2, 3]
    end
  end

  context "when reading vectors" do
    it "reads `#()` as an empty vector" do
      expect(read(%q(#()))).to eq Vector[]
    end

    it "reads `#(1 2 3)` as a vector" do
      expect(read(%q(#(1 2 3)))).to eq Vector[1, 2, 3]
    end

    it "reads `#(hello \"world\")` as a vector" do
      expect(read(%q(#(hello "world")))).to eq Vector[:hello, "world"]
    end
  end

  context "when reading functions" do
    %w(fn).each do |input|
      it "reads `#'#{input}` as a function object" do
        expect(read(%Q(#'#{input}))).to eq [:function, output = input.to_sym]
      end
    end

    {%q((lambda (x) x)) => [:lambda, [:x], :x]}.each do |input, output|
      it "reads `#'#{input}` as a function object" do
        expect(read(%Q(#'#{input}))).to eq [:function, output]
      end
    end
  end

  context "when reading quotations" do
    {%q((lambda (x) x)) => [:lambda, [:x], :x]}.each do |input, output|
      it "reads `'#{input}` as a quotation" do
        expect(read(%Q('#{input}))).to eq [:quote, output]
      end
    end
  end

  context "when reading comments" do
    it "reads `() ; a comment` as a list" do
      expect(read_all(%q(() ; a comment))).to eq [[]]
    end
  end

  def read(input, **options)
    SXP::Reader::CommonLisp.new(input.freeze, **options.freeze).read
  end

  def read_all(input, **options)
    SXP::Reader::CommonLisp.new(input.freeze, **options.freeze).read_all
  end
end
