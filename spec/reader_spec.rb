require File.join(File.dirname(__FILE__), 'spec_helper')

describe SXP::Reader::Basic do
  context "when reading empty input" do
    [
      '',
      ' ',
    ].each do |input|
      it "raises an error on #{input.inspect}" do
        expect {read(input)}.to raise_error(SXP::Reader::Error)
      end
    end
  end

  context "when reading valid symbols" do
    %w(: . \\ \n \t \r).each do |c|
      it "reads #{c.inspect} as a symbol" do
        expect(read(c)).to eq c.to_sym
      end
    end
  end

  context "when reading lists" do
    it "reads '()' as an empty list" do
      expect(read('()')).to eq []
    end

    it "reads '(1 2 3)' as a list" do
      expect(read('(1 2 3)')).to eq [1, 2, 3]
    end

    it "reads '(1 2 3) 4' as a list" do
      expect(read('(1 2 3) 4')).to eq [1, 2, 3]
    end
  end

  context "escapes in strings" do
    {
      %q{"\b"} => "\b",
      %q{"\f"} => "\f",
      %q{"\n"} => "\n",
      %q{"\r"} => "\r",
      %q{"\t"} => "\t",
      %q{"\u0080"} => "\u0080",
      %q("\u07FF") => "\u07FF",
      %q("\u0800") => "\u0800",
      %q("\u0FFF") => "\u0FFF",
      %q("\u1000") => "\u1000",
      %q("\uD000") => "\uD000",
      %q("\uD7FF") => "\uD7FF",
      %q("\uE000") => "\uE000",
      %q("\uFFFD") => "\uFFFD",
      %q("\U00010000") => "\u{10000}",
      %q("\U0003FFFD") => "\u{3FFFD}",
      %q("\U00040000") => "\u{40000}",
      %q("\U000FFFFD") => "\u{FFFFD}",
      %q("\U00100000") => "\u{100000}",
      %q("\U0010FFFD") => "\u{10FFFD}",
    }.each do |input, output|
      it "reads #{input} as #{output.inspect}" do
        expect(read(input)).to eq output
      end
    end
  end

  context "problematic examples" do
    {
      %q{"\t'[]()-"} => "\t'[]()-",
      %q{(range "\t'[]()-")} =>
        [:range, "\t'[]()-"],
      %q{(seq "\"" (star (alt CHAR (range "\t'[]()-"))) "\"")} =>
        [:seq, '"', [:star, [:alt, :CHAR, [:range, "\t'[]()-"]]], '"'],
    }.each do |input, output|
      it "reads #{input} as #{output.inspect}" do
        expect(read(input)).to eq output
      end
    end
  end

  context "when reading invalid input" do
    it "raises an error on '(1'" do
      expect { read_all('(1') }.to raise_error(SXP::Reader::Error)
    end

    it "raises an error on '1)'" do
      expect { read_all('1)') }.to raise_error(SXP::Reader::Error)
    end
  end

  it ".read_file" do
    expect(File).to receive(:open).with("foo.sxp", "rb").and_yield(StringIO.new("(1 2 3)\n(4 5 6)"))
    expect(SXP.read_file("foo.sxp")).to eq [[1, 2, 3], [4, 5, 6]]
  end

  it ".read_url" do
    expect(File).to receive(:open).with("http://example/foo.sxp", "rb").and_yield(StringIO.new("(1 2 3)\n(4 5 6)"))
    expect(SXP.read_file("http://example/foo.sxp")).to eq [[1, 2, 3], [4, 5, 6]]
  end

  def read(input, **options)
    SXP::Reader::Basic.read(input.freeze, **options)
  end

  def read_all(input, **options)
    SXP::Reader::Basic.read_all(input.freeze, **options)
  end
end
