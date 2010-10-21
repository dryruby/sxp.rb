require File.join(File.dirname(__FILE__), 'spec_helper')

describe SXP::Reader::SPARQL do
  context "when reading empty input" do
    it "raises an error" do
      lambda { read('') }.should raise_error(Reader::Error)
      lambda { read(' ') }.should raise_error(Reader::Error)
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

  context "when reading integer literals" do
    it "reads '123' as an xsd:integer" do
      read('123').should == RDF::Literal(123)
    end
  end

  context "when reading floating-point literals" do
    it "reads '123.0' as an xsd:double" do
      read('123.0').should == RDF::Literal(123.0)
    end
  end

  context "when reading datatyped literals" do
    it "reads '\"lex\"^^<http://example/thing>' as a datatyped literal" do
      read(%q("lex"^^<http://example.org/thing>)).should == RDF::Literal("lex", :datatype => 'http://example.org/thing')
    end
  end

  context "when reading variables" do
    it "reads '?x' as a variable" do
      read('?x').should == RDF::Query::Variable.new(:x)
    end

    it "reads '??0' as a non-distinguished variable" do
      read('??0').should == RDF::Query::Variable.new(:'?0') # FIXME?
    end

    it "reads '??' as a fresh non-distinguished variable with a random identifier" do
      read('??').should be_a(RDF::Query::Variable)
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
    it "reads 'ex:thing' as a prefixed name" do
      # TODO
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
  end

  context "when reading URIs" do
    it "reads '<...>' as a URI" do
      read('<>').should be_a(RDF::URI)
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
