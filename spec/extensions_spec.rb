require File.join(File.dirname(__FILE__), 'spec_helper')

describe "Core objects #to_sxp" do
  [
    [nil, '#n'],
    [false, '#f'],
    [true, '#t'],
    ['', '""'],
    ['string', '"string"'],
    [:symbol, 'symbol'],
    [1, '1'],
    [1.0, '1.0'],
    [BigDecimal("10"), '10.0'],
    [1.0e1, '10.0'],
    [Float::INFINITY, "+inf."],
    [-Float::INFINITY, "-inf."],
    [Float::NAN, "nan."],
    [['a', 2], '("a" 2)'],
    [Time.parse("2011-03-13T11:22:33Z"), '#@2011-03-13T11:22:33Z'],
    [/foo/, '#/foo/'],
  ].each do |(value, result)|
    it "returns #{result.inspect} for #{value.inspect}" do
      value.to_sxp.should == result
    end
  end
end

describe "RDF::Node#to_sxp" do
  specify { RDF::Node.new("a").to_sxp.should == %q(_:a)}
end

describe "RDF::Literal#to_sxp" do
  specify { RDF::Literal.new("a").to_sxp.should == %q("a")}
  specify { RDF::Literal.new("a", :language => "en-us").to_sxp.should == %q("a"@en-us)}
  if RDF::VERSION.to_s >= "1.1"
    specify { RDF::Literal.new("a", :datatype => RDF::XSD.string).to_sxp.should == %q("a")}
  else
    specify { RDF::Literal.new("a", :datatype => RDF::XSD.string).to_sxp.should == %q("a"^^<http://www.w3.org/2001/XMLSchema#string>)}
  end
  specify { RDF::Literal.new("2013-11-21", :datatype => RDF::XSD.date).to_sxp.should == %q("2013-11-21"^^<http://www.w3.org/2001/XMLSchema#date>)}
end

describe "RDF::URI#to_sxp" do
  specify { RDF::URI("http://example.com").to_sxp.should == %q(<http://example.com>)}

  it "uses lexical if defined" do
    u = RDF::URI("http://example.com/a")
    u.lexical = "foo:a"
    u.to_sxp.should == %q(foo:a)
  end
end

describe "RDF::Query::Variable#to_sxp" do
  specify { RDF::Query::Variable.new("a").to_sxp.should == %q(?a)}
  it "generates ??0 for non-distinguished variable" do
    v = RDF::Query::Variable.new("0")
    v.distinguished = false
    v.to_sxp.should == %q(??0)
  end
end

describe "RDF::Query::Pattern#to_sxp" do
  {
    RDF::Query::Pattern.new(RDF::URI("a"), RDF::URI("b"), RDF::URI("c")) => %q((triple <a> <b> <c>)),
    RDF::Query::Pattern.new(RDF::URI("a"), RDF::Query::Variable.new("b"), RDF::Literal.new("c")) =>
      %q((triple <a> ?b "c"))
  }.each_pair do |st, sxp|
    it "generates #{sxp} given #{st}" do
      st.to_sxp.should == sxp
    end
  end
end

describe "RDF::Query#to_sxp" do
  {
    RDF::Query.new {
      pattern [RDF::URI("a"), RDF::URI("b"), RDF::URI("c")]
    } => %q((bgp (triple <a> <b> <c>))),
    RDF::Query.new {
      pattern [RDF::URI("a"), RDF::URI("b"), RDF::URI("c")]
      pattern [RDF::URI("d"), RDF::URI("e"), RDF::URI("f")]
    } => %q((bgp (triple <a> <b> <c>) (triple <d> <e> <f>))),
    RDF::Query.new() {} => %q((bgp)),
    RDF::Query.new(:context => false) {} => %q((bgp)),
    RDF::Query.new(:context => RDF::URI("http://example.com/")) {
      pattern [RDF::URI("a"), RDF::URI("b"), RDF::URI("c")]
    } => %q((graph <http://example.com/> (bgp (triple <a> <b> <c>)))),
  }.each_pair do |st, sxp|
    it "generates #{sxp} given #{st.inspect}" do
      st.to_sxp.should == sxp
    end
  end
end