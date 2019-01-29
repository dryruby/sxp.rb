# -*- encoding: utf-8 -*-
require File.join(File.dirname(__FILE__), 'spec_helper')

describe SXP::Reader::SPARQL do
  context "when reading empty input" do
    it "raises an error" do
      expect { read('') }.to raise_error(Reader::Error)
      expect { read(' ') }.to raise_error(Reader::Error)
    end
  end

  context "when reading nil" do
    it "reads 'nil' as nil" do
      expect(read(%q(nil))).to be_nil
    end
  end

  context "terms" do
    {
      %q("")         => RDF::Literal(""),
      %q("hello")    => RDF::Literal("hello"),
      %q(""@en)      => RDF::Literal("", language: :en),
      %q("hello"@en) => RDF::Literal("hello", language: :en),
      %q("hello"@en-US) => RDF::Literal("hello", language: :'en-us'),
      %q("hello"@EN) => RDF::Literal("hello", language: :en),
      'true' => RDF::Literal(true),
      'false' => RDF::Literal(false),
      '123' => RDF::Literal(123),
      '-18' => RDF::Literal(-18),
      '123.0' => RDF::Literal::Decimal.new(123.0),
      '456.' => RDF::Literal::Decimal.new(456.0),
      '1.0e0' => [
        RDF::Literal::Double.new(1.0e0),
        RDF::Literal::Double.new('1.0e0')
      ],
      '1.0E+6' => [
        RDF::Literal::Double.new(1.0e6),
        RDF::Literal::Double.new(1_000_000.0),
        RDF::Literal::Double.new('1.0e6'),
      ],
      '1.0E-6' => RDF::Literal::Double.new(1/1_000_000.0),
      %q("lex"^^<http://example.org/thing>) => RDF::Literal("lex", datatype: 'http://example.org/thing'),
      '?x' => RDF::Query::Variable.new(:x),
    }.each do |input, result|
      it "reads #{input.inspect} as #{[result].flatten.inspect}" do
        [result].flatten.each do |r|
          expect(read(input)).to eq r
        end
      end
    end

    {
      '123.0' => RDF::Literal::Decimal.new(123.0),
      '456.' => RDF::Literal::Decimal.new('456.'),
      '1.0e0' => RDF::Literal::Double.new('1.0e0'),
      '1.0E+6' => RDF::Literal::Double.new('1.0E+6'),
    }.each do |input, result|
      it "reads #{input.inspect} as eql #{[result].flatten.inspect}" do
        [result].flatten.each do |r|
          expect(read(input)).to eql r
        end
      end
    end
  end

  context "when reading datatyped literals" do
    it "reads '(prefix ((: <http://example.org/>)) \"lex\"^^:thing)' as a datatyped literal" do
      expect(read(%q((prefix ((: <http://example.org/>)) "lex"^^:thing)))).to eq [:prefix, [[:":", RDF::URI("http://example.org/")]], RDF::Literal("lex", datatype: 'http://example.org/thing')]
    end
  end

  context "when reading variables" do
    {
      '?' => [RDF::Query::Variable, true, false],
      '?x' => [RDF::Query::Variable.new("x"), true, false],
      '??0' => [RDF::Query::Variable.new("0"), false, false],
      '?.1' => [RDF::Query::Variable.new("1"), false, false],
      '?.' => [RDF::Query::Variable, false, false],
      '??.1' => [RDF::Query::Variable.new("1"), false, false],
      '??' => [RDF::Query::Variable, false, false],
      '$' => [RDF::Query::Variable, true, true],
      '$x' => [RDF::Query::Variable.new("x"), true, true],
      '$$0' => [RDF::Query::Variable.new("0"), false, true],
      '$.1' => [RDF::Query::Variable.new("1"), false, true],
      '$.' => [RDF::Query::Variable.new, false, true],
      '$$.1' => [RDF::Query::Variable.new("1"), false, true],
      '$$' => [RDF::Query::Variable, false, true],
    }.each do |input, (result, distinguished, existential)|
      describe "given #{input}" do
        subject {read(input)}
        if result.is_a?(Class)
          it {is_expected.to be_a(result)}
        else
          it {is_expected.to eq result}
        end
        if distinguished
          it {is_expected.to be_distinguished}
        else
          it {is_expected.not_to be_distinguished}
        end
        if existential
          it {is_expected.to be_existential}
        else
          it {is_expected.not_to be_existential}
        end
      end
    end

    it "reads ?x .. ?x as the identical variable" do
      sxp = read('(?x ?x)')
      expect(sxp[0]).to eq RDF::Query::Variable.new(:x)
      expect(sxp[1]).to eq RDF::Query::Variable.new(:x)
      expect(sxp[0]).to be_equal(sxp[1])
      expect(sxp[0]).to be_distinguished
    end
  end

  context "when reading blank nodes" do
    {
      '_:abc' => RDF::Node(:abc),
      '_:' => RDF::Node,
      '_:o' => RDF::Node(:o),
      '_:0' => RDF::Node(:"0"),
      '_:_' => RDF::Node(:_),
      # Problems with JRuby
      #'_:a·̀ͯ‿.⁀' => RDF::Node("a·̀ͯ‿.⁀"),
      #'_:AZazÀÖØöø˿ͰͽͿ῿‌‍⁰' => RDF::Node('AZazÀÖØöø˿ͰͽͿ῿‌‍⁰')
    }.each do |input, result|
      describe "given #{input}" do
        subject {read(input)}
        if result.is_a?(Class)
          it {is_expected.to be_a(result)}
        else
          it {is_expected.to eq result}
        end
      end
    end
  end

  context "when reading prefixed names" do
    it "reads 'ex:thing' as a symbol" do
      expect(read('ex:thing')).to eq :"ex:thing"
    end
    
    it "reads '(prefix ((ex: <foo#>)) ex:bar)' as <foo#bar>" do
      expect(read('(prefix ((ex: <foo#>)) ex:bar)')).to eq [:prefix, [[:"ex:", RDF::URI("foo#")]], RDF::URI("foo#bar")]
    end

    it "reads '(prefix ((ex: <foo#>) (: <bar#>)) ex:bar bar:baz)' as <foo#bar> <bar#baz>" do
      expect(read('
        (prefix
          ((ex: <foo#>) (: <bar#>))
          ex:bar :baz)')).to eq [
        :prefix,
          [[:"ex:", RDF::URI("foo#")], [:":", RDF::URI("bar#")]],
          RDF::URI("foo#bar"), RDF::URI("bar#baz")]
    end

    it "reads adds lexical to URI" do
      expect(read('(prefix ex: <foo#> ex:bar)').last.lexical).to eq "ex:bar"
    end
  end

  context "when reading symbols" do
    {
      ':' => :':',
      '.' => :'.',
      '\\' => :'\\',
      '@xyz' => :@xyz,
      '< ' => :'<',
      '<' => :'<',
      '(<)' => [:'<'],
      '<= ' => :'<=',
      '<=' => :'<=',
      '(<=)' => [:'<='],
      'a' => RDF.type,
    }.each do |input, result|
      it "reads #{input.inspect} as #{result.inspect}" do
        expect(read(input)).to eq result
      end
    end

    it "remembers lexical form of 'a'" do
      expect(read('a').lexical).to eq 'a'
    end
  end

  context "when reading IRIs" do
    {
      '<>' => RDF::URI,
      %q(<scheme:!$%25&amp;'()*+,-./0123456789:/@ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz~?#>) =>
        RDF::URI(%q(scheme:!$%25&amp;'()*+,-./0123456789:/@ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz~?#)),
      %q(<http://a.example/\\U00000073>) => RDF::URI('http://a.example/\\U00000073'),
      %q(<http://a.example/\\u0073>) => RDF::URI('http://a.example/\\u0073'),
      %q(<eXAMPLE://a/./b/../b/%63/%7bfoo%7d#>) => RDF::URI('eXAMPLE://a/./b/../b/%63/%7bfoo%7d#'),
    }.each do |input, result|
      describe "given #{input}" do
        subject {read(input)}
        if result.is_a?(Class)
          it {is_expected.to be_a(result)}
        else
          it {is_expected.to eq result}
        end
      end
    end

    context "with base" do
      {
        ['', 'a'] => "<a>",
        ['', 'http://foo/bar#'] => "<http://foo/bar#>",
        ['', 'http://resource1'] => "<http://resource1>",
      
        %w(http://example.org foo) => "<http://example.org/foo>",
        %w(http://example.org foo#bar) => "<http://example.org/foo#bar>",
        %w(http://foo ) =>  "<http://foo>",
        %w(http://foo a) => "<http://foo/a>",
        %w(http://foo /a) => "<http://foo/a>",
        %w(http://foo #a) => "<http://foo#a>",
      
        %w(http://foo/ ) =>  "<http://foo/>",
        %w(http://foo/ a) => "<http://foo/a>",
        %w(http://foo/ /a) => "<http://foo/a>",
        %w(http://foo/ #a) => "<http://foo/#a>",

        %w(http://foo# ) =>  "<http://foo#>",
        %w(http://foo# a) => "<http://foo/a>",
        %w(http://foo# /a) => "<http://foo/a>",
        %w(http://foo# #a) => "<http://foo#a>",

        %w(http://foo/bar ) =>  "<http://foo/bar>",
        %w(http://foo/bar a) => "<http://foo/a>",
        %w(http://foo/bar /a) => "<http://foo/a>",
        %w(http://foo/bar #a) => "<http://foo/bar#a>",

        %w(http://foo/bar/ ) =>  "<http://foo/bar/>",
        %w(http://foo/bar/ a) => "<http://foo/bar/a>",
        %w(http://foo/bar/ /a) => "<http://foo/a>",
        %w(http://foo/bar/ #a) => "<http://foo/bar/#a>",

        %w(http://foo/bar# ) =>  "<http://foo/bar#>",
        %w(http://foo/bar# a) => "<http://foo/a>",
        %w(http://foo/bar# /a) => "<http://foo/a>",
        %w(http://foo/bar# #a) => "<http://foo/bar#a>",

        %w(http://a/bb/ccc/.. g:h) => "<g:h>",
        %w(http://a/bb/ccc/.. g) => "<http://a/bb/ccc/g>",
        %w(http://a/bb/ccc/.. ./g) => "<http://a/bb/ccc/g>",
        %w(http://a/bb/ccc/.. g/) => "<http://a/bb/ccc/g/>",
        %w(http://a/bb/ccc/.. ?y) => "<http://a/bb/ccc/..?y>",
        %w(http://a/bb/ccc/.. g?y) => "<http://a/bb/ccc/g?y>",
        %w(http://a/bb/ccc/.. #s) => "<http://a/bb/ccc/..#s>",
        %w(http://a/bb/ccc/.. g#s) => "<http://a/bb/ccc/g#s>",

        %w(file:///a/bb/ccc/d;p?q g) => "<file:///a/bb/ccc/g>",
        %w(http://a/b eXAMPLE://a/./b/../b/%63/%7bfoo%7d#) => "<eXAMPLE://a/./b/../b/%63/%7bfoo%7d#>"
      }.each do |(lhs, rhs), result|
        it "reads (base <#{lhs}> <#{rhs}>) as #{result}" do
          sse = read(%((base <#{lhs}> <#{rhs}>)))
          expect(sse).to eq [:base, RDF::URI(lhs), RDF::URI(result[1..-2])]
          expect(sse.last).to eq RDF::URI(result[1..-2])
          expect(sse.last.lexical).to eq "<#{rhs}>" if sse.last.lexical
        end
      end
    end
  end

  context "when reading lists" do
    it "reads '()' as an empty array" do
      expect(read('()')).to eq []
    end

    it "reads '[]' as an empty array" do
      expect(read('[]')).to eq []
    end

    it "reads '(1 2 3)' as an array" do
      expect(read('(1 2 3)')).to eq [1, 2, 3].map { |n| RDF::Literal(n) }
    end

    it "reads '[1 2 3]' as an array" do
      expect(read('[1 2 3]')).to eq [1, 2, 3].map { |n| RDF::Literal(n) }
    end
  end

  context "when reading comments" do
    it "reads '() ; a comment' as a list" do
      expect(read_all('() ; a comment')).to eq [[]]
    end

    it "reads '[] ; a comment' as a list" do
      expect(read_all('[] ; a comment')).to eq [[]]
    end
  end

  def read(input, options = {})
    SXP::Reader::SPARQL.new(input, options).read
  end

  def read_all(input, options = {})
    SXP::Reader::SPARQL.new(input.freeze, options).read_all
  end
end
