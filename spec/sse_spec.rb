require File.join(File.dirname(__FILE__), 'spec_helper')

describe SXP::Reader::SSE do
  context "when reading empty input" do
    it "should complain" do
      lambda { read('') }.should raise_error(Reader::Error)
      lambda { read(' ') }.should raise_error(Reader::Error)
    end
  end

  context "when reading plain literals" do
    it "should read '\"\"' as a plain string literal" do
      read(%q("")).should == RDF::Literal("")
    end

    it "should read '\"hello\"' as a plain string literal" do
      read(%q("hello")).should == RDF::Literal("hello")
    end
  end

  context "when reading language-tagged literals" do
    it "should read '\"\"@en' as a language-tagged literal" do
      read(%q(""@en)).should == RDF::Literal("", :language => :en)
    end

    it "should read '\"hello\"@en' as a language-tagged literal" do
      read(%q("hello"@en)).should == RDF::Literal("hello", :language => :en)
    end

    it "should read '\"hello\"@en-US' as a language-tagged literal" do
      read(%q("hello"@en-US)).should == RDF::Literal("hello", :language => :'en-US')
    end
  end

  context "when reading integer literals" do
    it "should read '123' as an xsd:integer" do
      read('123').should == RDF::Literal(123)
    end
  end

  context "when reading datatyped literals" do
    it "should read '\"lex\"^^<http://example/thing>' as a datatyped literal" do
      read(%q("lex"^^<http://example.org/thing>)).should == RDF::Literal("lex", :datatype => 'http://example.org/thing')
    end
  end

  context "when reading variables" do
    it "should read '?x' as a variable" do
      read('?x').should == RDF::Query::Variable.new(:x)
    end
  end

  context "when reading blank nodes" do
    it "should read '_:' as a blank node with a random identifier" do
      read('_:').should be_a(RDF::Node)
    end

    it "should read '_:abc' as a blank node with identifier :abc" do
      read('_:abc').should == RDF::Node(:abc)
    end
  end

  context "when reading prefixed names" do
    it "should read 'ex:thing' as a prefixed name" do
      # TODO
    end
  end

  context "when reading symbols" do
    it "should read ':' as a symbol" do
      read(':').should == :':'
    end

    it "should read '.' as a symbol" do
      read('.').should == :'.'
    end

    it "should read '\\' as a symbol" do
      read('\\').should == :'\\'
    end

    it "should read '@xyz' as a symbol" do
      read('@xyz').should == :@xyz
    end
  end

  context "when reading URIs" do
    it "should read '<...>' as a URI" do
      read('<>').should be_a(RDF::URI)
    end
  end

  context "when reading lists" do
    it "should read '()' as an empty array" do
      read('()').should == []
    end

    it "should read '[]' as an empty array" do
      read('[]').should == []
    end

    it "should read '(1 2 3)' as an array" do
      read('(1 2 3)').should == [1, 2, 3].map { |n| RDF::Literal(n) }
    end

    it "should read '[1 2 3]' as an array" do
      read('[1 2 3]').should == [1, 2, 3].map { |n| RDF::Literal(n) }
    end
  end

  context "when reading comments" do
    it "should read '() ; a comment' as a list" do
      read_all('() ; a comment').should == [[]]
    end

    it "should read '[] ; a comment' as a list" do
      read_all('[] ; a comment').should == [[]]
    end
  end

  def read(input, options = {})
    SXP::Reader::SSE.new(input, options).read
  end

  def read_all(input, options = {})
    SXP::Reader::SSE.new(input, options).read_all
  end
end
