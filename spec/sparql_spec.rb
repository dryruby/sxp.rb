# -*- encoding: utf-8 -*-
require File.join(File.dirname(__FILE__), 'spec_helper')

describe SXP::Reader::SPARQL do
  context "when reading empty input" do
    it "raises an error" do
      lambda { read('') }.should raise_error(Reader::Error)
      lambda { read(' ') }.should raise_error(Reader::Error)
    end
  end

  context "when reading nil" do
    it "reads 'nil' as nil" do
      read(%q(nil)).should be_nil
    end
  end

  context "terms" do
    {
      %q("")         => RDF::Literal(""),
      %q("hello")    => RDF::Literal("hello"),
      %q(""@en)      => RDF::Literal("", :language => :en),
      %q("hello"@en) => RDF::Literal("hello", :language => :en),
      %q("hello"@en-US) => RDF::Literal("hello", :language => :'en-us'),
      %q("hello"@EN) => RDF::Literal("hello", :language => :en),
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
      %q("lex"^^<http://example.org/thing>) => RDF::Literal("lex", :datatype => 'http://example.org/thing'),
      '?x' => RDF::Query::Variable.new(:x),
    }.each do |input, result|
      it "reads #{input.inspect} as #{[result].flatten.inspect}" do
        [result].flatten.each do |r|
          read(input).should == r
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
          read(input).should be_eql(r)
        end
      end
    end
  end

  context "when reading datatyped literals" do
    it "reads '(prefix ((: <http://example.org/>)) \"lex\"^^:thing)' as a datatyped literal" do
      read(%q((prefix ((: <http://example.org/>)) "lex"^^:thing))).should == [:prefix, [[:":", RDF::URI("http://example.org/")]], RDF::Literal("lex", :datatype => 'http://example.org/thing')]
    end
  end

  context "when reading variables" do
    {
      '?' => [RDF::Query::Variable, true],
      '?x' => [RDF::Query::Variable.new(:"x"), true],
      '??0' => [RDF::Query::Variable.new(:"0"), false],
      '?.1' => [RDF::Query::Variable.new(:".1"), false],
      '??' => [RDF::Query::Variable, false],
    }.each do |input, (result, distinguished)|
      describe "given #{input}" do
        subject {read(input)}
        if result.is_a?(Class)
          it {should be_a(result)}
        else
          it {should == result}
        end
        if distinguished
          it {should be_distinguished}
        else
          it {should_not be_distinguished}
        end
      end
    end

    it "reads ?x .. ?x as the identical variable" do
      sxp = read('(?x ?x)')
      sxp[0].should == RDF::Query::Variable.new(:x)
      sxp[1].should == RDF::Query::Variable.new(:x)
      sxp[0].should be_equal(sxp[1])
      sxp[0].should be_distinguished
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
          it {should be_a(result)}
        else
          it {should == result}
        end
      end
    end
  end

  context "when reading prefixed names" do
    it "reads 'ex:thing' as a symbol" do
      read('ex:thing').should == :"ex:thing"
    end
    
    it "reads '(prefix ((ex: <foo#>)) ex:bar)' as <foo#bar>" do
      read('(prefix ((ex: <foo#>)) ex:bar)').should == [:prefix, [[:"ex:", RDF::URI("foo#")]], RDF::URI("foo#bar")]
    end

    it "reads '(prefix ((ex: <foo#>) (: <bar#>)) ex:bar bar:baz)' as <foo#bar> <bar#baz>" do
      read('
        (prefix
          ((ex: <foo#>) (: <bar#>))
          ex:bar :baz)').should ==
        [:prefix,
          [[:"ex:", RDF::URI("foo#")], [:":", RDF::URI("bar#")]],
          RDF::URI("foo#bar"), RDF::URI("bar#baz")]
    end

    it "reads adds lexical to URI" do
      read('(prefix ex: <foo#> ex:bar)').last.lexical.should == "ex:bar"
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
        read(input).should == result
      end
    end

    it "remembers lexical form of 'a'" do
      read('a').lexical.should == 'a'
    end
  end

  context "when reading IRIs" do
    {
      '<>' => RDF::URI,
      %q(<scheme:!$%25&amp;'()*+,-./0123456789:/@ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz~?#>) =>
        RDF::URI(%q(scheme:!$%25&amp;'()*+,-./0123456789:/@ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz~?#)),
      %q(<http://a.example/\\U00000073>) => RDF::URI('http://a.example/\\U00000073'),
      %q(<http://a.example/\\u0073>) => RDF::URI('http://a.example/\\u0073')
    }.each do |input, result|
      describe "given #{input}" do
        subject {read(input)}
        if result.is_a?(Class)
          it {should be_a(result)}
        else
          it {should == result}
        end
      end
    end

    it "reads (base <prefix/> <suffix>) as <prefix/suffix>" do
      sse = read(%q((base <prefix/> <suffix>)))
      sse.should == [:base, RDF::URI('prefix/'), RDF::URI('prefix/suffix')]
      sse.last.should == RDF::URI('prefix/suffix')
      sse.last.lexical.should == '<suffix>'
    end
  end

  context "when reading lists" do
    it "reads '()' as an empty array" do
      read('()').should == []
    end

    it "reads '[]' as an empty array" do
      read('[]').should == []
    end

    it "reads '(1 2 3)' as an array" do
      read('(1 2 3)').should == [1, 2, 3].map { |n| RDF::Literal(n) }
    end

    it "reads '[1 2 3]' as an array" do
      read('[1 2 3]').should == [1, 2, 3].map { |n| RDF::Literal(n) }
    end
  end

  context "when reading comments" do
    it "reads '() ; a comment' as a list" do
      read_all('() ; a comment').should == [[]]
    end

    it "reads '[] ; a comment' as a list" do
      read_all('[] ; a comment').should == [[]]
    end
  end

  def read(input, options = {})
    SXP::Reader::SPARQL.new(input, options).read
  end

  def read_all(input, options = {})
    SXP::Reader::SPARQL.new(input.freeze, options).read_all
  end
end
