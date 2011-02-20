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

  context "when reading plain literals" do
    it "reads '\"\"' as a plain string literal" do
      read(%q("")).should == RDF::Literal("")
    end

    it "reads '\"hello\"' as a plain string literal" do
      read(%q("hello")).should == RDF::Literal("hello")
    end
  end

  context "when reading language-tagged literals" do
    it "reads '\"\"@en' as a language-tagged literal" do
      read(%q(""@en)).should == RDF::Literal("", :language => :en)
    end

    it "reads '\"hello\"@en' as a language-tagged literal" do
      read(%q("hello"@en)).should == RDF::Literal("hello", :language => :en)
    end

    it "reads '\"hello\"@en-US' as a language-tagged literal" do
      read(%q("hello"@en-US)).should == RDF::Literal("hello", :language => :'en-US')
    end
  end

  context "when reading boolean literals" do
    it "reads 'true' as an xsd:boolean" do
      read('true').should == RDF::Literal(true)
    end

    it "reads 'false' as an xsd:boolean" do
      read('false').should == RDF::Literal(false)
    end
  end

  context "when reading integer literals" do
    it "reads '123' as an xsd:integer" do
      read('123').should == RDF::Literal(123)
    end

    it "reads '-18' as an xsd:integer" do
      read('-18').should == RDF::Literal(-18)
    end
  end

  context "when reading floating-point literals" do
    it "reads '123.0' as an xsd:double" do
      read('123.0').should == RDF::Literal(123.0)
    end

    it "reads '456.' as an xsd:double" do
      read('456.').should == RDF::Literal(456.0)
    end

    it "reads '456.0' as an xsd:double" do
      read('456.0').should == RDF::Literal(456.0)
    end

    it "reads '1.0e0' as an xsd:double" do
      read('1.0e0').should == RDF::Literal(1.0)
    end

    it "reads '1.0E+6' as an xsd:double" do
      read('1.0E+6').should == RDF::Literal(1_000_000.0)
    end

    it "reads '1.0E-6' as an xsd:double" do
      read('1.0E-6').should == RDF::Literal(1/1_000_000.0)
    end
  end

  context "when reading datatyped literals" do
    it "reads '\"lex\"^^<http://example/thing>' as a datatyped literal" do
      read(%q("lex"^^<http://example.org/thing>)).should == RDF::Literal("lex", :datatype => 'http://example.org/thing')
    end

    it "reads '(prefix ((: <http://example.org/>)) \"lex\"^^:thing)' as a datatyped literal" do
      read(%q((prefix ((: <http://example.org/>)) "lex"^^:thing))).should == [:prefix, [[:":", RDF::URI("http://example.org/")]], RDF::Literal("lex", :datatype => 'http://example.org/thing')]
    end
  end

  context "when reading variables" do
    it "reads '?x' as a variable" do
      read('?x').should == RDF::Query::Variable.new(:x)
    end

    it "reads '?' as a variable" do
      v = read('?')
      v.should be_a(RDF::Query::Variable)
      v.should be_distinguished
    end
    
    it "reads ?x .. ?x as the identical variable" do
      sxp = read('(?x ?x)')
      sxp[0].should == RDF::Query::Variable.new(:x)
      sxp[1].should == RDF::Query::Variable.new(:x)
      sxp[0].should be_equal(sxp[1])
      sxp[0].should be_distinguished
    end

    it "reads '??0' as a non-distinguished variable" do
      v = read('??0')
      v.should == RDF::Query::Variable.new(:"0")
      v.should_not be_distinguished
    end

    it "reads '??' as a fresh non-distinguished variable with a random identifier" do
      v = read('??')
      v.should be_a(RDF::Query::Variable)
      v.should_not be_distinguished
    end
  end

  context "when reading blank nodes" do
    it "reads '_:abc' as a blank node with identifier :abc" do
      read('_:abc').should == RDF::Node(:abc)
    end

    it "reads '_:' as a fresh blank node with a random identifier" do
      read('_:').should be_a(RDF::Node)
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

    it "reads adds qname to URI" do
      read('(prefix ex: <foo#> ex:bar)').last.qname.should == "ex:bar"
    end
  end

  context "when reading symbols" do
    it "reads ':' as a symbol" do
      read(':').should == :':'
    end

    it "reads '.' as a symbol" do
      read('.').should == :'.'
    end

    it "reads '\\' as a symbol" do
      read('\\').should == :'\\'
    end

    it "reads '@xyz' as a symbol" do
      read('@xyz').should == :@xyz
    end

    it "reads '<' as a symbol" do
      read('< ').should == :'<'
      read('<').should == :'<'
      read('(<)').should == [:'<']
    end

    it "reads '<=' as a symbol" do
      read('<= ').should == :'<='
      read('<=').should == :'<='
      read('(<=)').should == [:'<=']
    end
  end

  context "when reading URIs" do
    it "reads '<...>' as a URI" do
      read('<>').should be_a(RDF::URI)
    end

    it "reads (base <prefix/> <suffix>) as <prefix/suffix>" do
      read(%q((base <prefix/> <suffix>))).should == [:base, RDF::URI('prefix/'), RDF::URI('prefix/suffix')]
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
    SXP::Reader::SPARQL.new(input.freeze, options).read
  end

  def read_all(input, options = {})
    SXP::Reader::SPARQL.new(input.freeze, options).read_all
  end
end
