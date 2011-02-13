require File.join(File.dirname(__FILE__), 'spec_helper')

describe "RDF::Node#to_sxp" do
  specify { RDF::Node.new("a").to_sxp.should == %q("_:a")}
end

describe "RDF::Literal#to_sxp" do
  specify { RDF::Literal.new("a").to_sxp.should == %q("a")}
  specify { RDF::Literal.new("a", :language => "en-us").to_sxp.should == %q("a"@en-us)}
  specify { RDF::Literal.new("a", :datatype => RDF::XSD.string).to_sxp.should == %q("a"^^<http://www.w3.org/2001/XMLSchema#string>)}
end

describe "RDF::URI#to_sxp" do
  specify { RDF::URI("http://example.com").to_sxp.should == %q(<http://example.com>)}
end

describe "RDF::Query::Variable#to_sxp" do
  specify { RDF::Query::Variable.new("a").to_sxp.should == %q(?a)}
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
    RDF::Query.new() {} => %q((bgp))
  }.each_pair do |st, sxp|
    it "generates #{sxp} given #{st.inspect}" do
      st.to_sxp.should == sxp
    end
  end
  
  {
    RDF::Query.new(nil, :context => RDF::URI("http://example.com/")) {
      pattern [RDF::URI("a"), RDF::URI("b"), RDF::URI("c")]
    } => %q((graph <http://example.com/> (bgp (triple <a> <b> <c>)))),
  }.each_pair do |st, sxp|
    it "generates #{sxp} given #{st.inspect}" do
      pending("named query support") {st.to_sxp.should == sxp}
    end    
  end
end