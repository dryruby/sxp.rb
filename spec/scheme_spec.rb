require File.join(File.dirname(__FILE__), 'spec_helper')

describe SXP::Reader::Scheme do
  context "when reading empty input" do
    [
      '',
      ' ',
      '#!/usr/bin/env sxp2json'
    ].each do |input|
      it "raises an error on #{input.inspect}" do
        expect {read(input)}.to raise_error(SXP::Reader::Error)
      end
    end
  end

  context "when reading shebang scripts" do
    it "ignores shebang lines" do
      expect(read_all("#!/usr/bin/env sxp2json\n(1 2 3)\n")).to eq [[1, 2, 3]]
    end
  end

  context "when reading symbols" do
    %w(lambda list->vector + <=? q soup V17a a34kTMNs the-word-recursion-has-many-meanings).each do |symbol|
      it "reads '#{symbol}' as a symbol" do
        expect(read(%Q(#{symbol}))).to eq symbol.to_sym
      end
    end
  end

  context "when reading strings" do
    it "reads '\"foo\"' as a string" do
      expect(read(%q("foo"))).to eq "foo"
    end
  end

  context "sharp sequences" do
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
          expect(read(input)).to eq output
        end
      end
    end

    context "when reading integers" do
      {
        '#b1010' => 0b1010,
        '#B1010' => 0b1010,
        '#o755' => 0755,
        '#O755' => 0755,
        '123' => 123,
        '#d123' => 123,
        '#D123' => 123,
        '#xFF' => 0xFF,
        '#XFF' => 0xFF,
        '#xff' => 0xFF,
        '#Xff' => 0xFF,
      }.each do |input, output|
        it "reads #{input} as an integer" do
          expect(read(input)).to eq output
        end
      end
    end

    context "when reading #n" do
      it "reads '#n' as NULL" do
        expect(read(%q(#n))).to be_nil
      end
    end

    context "when reading #;" do
      it "reads '#;' as an empty string" do
        expect(read(%q(#;[]))).to eq []
      end
    end

    context "when reading #!" do
      it "reads '#!/usr/bin/env sxp2json\nfoo' as an empty string" do
        expect(read(%(#!/usr/bin/env sxp2json\n[]))).to eq []
      end
    end
  end

  context "when reading floats" do
    it "reads '3.1415' as a float" do
      expect(read(%q(3.1415))).to eq 3.1415
    end
  end

  context "when reading fractions" do
    it "reads '1/2' as a rational" do
      expect(read(%q(1/2))).to eq Rational(1, 2)
    end
  end

  context "when reading booleans" do
    it "reads '#t' as true" do
      expect(read(%q(#t))).to eq true
    end

    it "reads '#T' as true" do
      expect(read(%q(#T))).to eq true
    end

    it "reads '#f' as false" do
      expect(read(%q(#f))).to eq false
    end

    it "reads '#F' as false" do
      expect(read(%q(#F))).to eq false
    end
  end

  context "when reading lists" do
    it "reads '()' as an empty list" do
      expect(read(%q(()))).to eq [] # FIXME
    end

    it "reads '[]' as an empty list" do
      expect(read('[]')).to eq []
    end

    it "reads '[] 1' as an empty list" do
      expect(read('[] 1')).to eq []
    end

    it "reads '(1 2 3)' as a list" do
      expect(read(%((1 2 3)))).to eq [1, 2, 3]
    end

    it "reads '(1 2 3) 4' as a list" do
      expect(read('(1 2 3) 4')).to eq [1, 2, 3]
    end

    it "reads '[1 2 3]' as a list" do
      expect(read('[1 2 3]')).to eq [1, 2, 3]
    end
  end

  context "when reading vectors", pending: "Support for vectors" do
    it "reads '#()' as an empty vector" do
      expect(read(%q(#()))).to eq []
    end

    it "reads '#(1 2 3)' as a vector" do
      expect(read(%q(#(1 2 3)))).to eq [1, 2, 3]
    end
  end

  context "when reading comments" do
    it "reads '() ; a comment' as a list" do
      expect(read_all('() ; a comment')).to eq [[]]
    end
  end

  context "when reading invalid input" do
    it "raises an error on '[1'" do
      expect { read_all('[1') }.to raise_error(SXP::Reader::Error)
    end

    it "raises an error on '1]'" do
      expect { read_all('1]') }.to raise_error(SXP::Reader::Error)
    end

    it "raises an error on '[1)'" do
      expect { read_all('[1)') }.to raise_error(SXP::Reader::Error) # FIXME
    end
  end

  def read(input, **options)
    SXP::Reader::Scheme.new(input.freeze, **options.freeze).read
  end

  def read_all(input, **options)
    SXP::Reader::Scheme.new(input.freeze, **options.freeze).read_all
  end
end
