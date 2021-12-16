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
    [Float::INFINITY, "+inf.0"],
    [-Float::INFINITY, "-inf.0"],
    [Float::NAN, "nan.0"],
    [['a', 2], '("a" 2)'],
    [Time.parse("2011-03-13T11:22:33Z"), '#@2011-03-13T11:22:33Z'],
    [/foo/, '#/foo/'],
    [{a: 'b'}, %q(((a "b")))],
  ].each do |(value, result)|
    it "returns #{result.inspect} for #{value.inspect}" do
      expect(value.to_sxp).to eq result
    end
  end
end

describe "RDF::Node#to_sxp" do
  specify { expect(RDF::Node.new("a").to_sxp).to eq %q(_:a)}
end

describe "RDF::Literal#to_sxp" do
  {
    RDF::Literal.new("a") => %q("a"),
    RDF::Literal.new("a", language: "en-us") => %q("a"@en-us),
    RDF::Literal.new("2013-11-21", datatype: RDF::XSD.date) => %q("2013-11-21"^^<http://www.w3.org/2001/XMLSchema#date>),
    RDF::Literal(1) => %q(1),
    RDF::Literal::Decimal.new(1.0) => '1.0',
    RDF::Literal(1.0e1) => '1.0e1',
    RDF::Literal(Float::INFINITY) => "+inf.0",
    RDF::Literal(-Float::INFINITY) => "-inf.0",
    RDF::Literal(Float::NAN) => "nan.0",
  }.each_pair do |l, sxp|
    specify {expect(l.to_sxp).to eq sxp}
  end
end

describe "RDF::Literal#to_sxp with prefix" do
  specify { expect(RDF::Literal.new("2013-11-21", datatype: RDF::XSD.date).to_sxp(prefixes: {xsd: RDF::XSD.to_uri})).to eq %q("2013-11-21"^^xsd:date)}
end

describe "RDF::URI#to_sxp" do
  specify { expect(RDF::URI("http://example.com").to_sxp).to eq %q(<http://example.com>)}

  it "uses lexical if defined" do
    u = RDF::URI("http://example.com/a")
    u.lexical = "foo:a"
    expect(u.to_sxp).to eq %q(foo:a)
  end

  it "uses prefix if defined" do
    u = RDF::URI("http://example.com/a")
    expect(u.to_sxp(prefixes: {foo: 'http://example.com/'})).to eq %q(foo:a)
  end

  it "uses base if defined" do
    u = RDF::URI("http://example.com/a")
    expect(u.to_sxp(base_uri: 'http://example.com/')).to eq %q(<a>)
  end
end

describe "RDF::Query::Variable#to_sxp" do
  specify { expect(RDF::Query::Variable.new("a").to_sxp).to eq %q(?a)}
  it "generates ??0 for non-distinguished variable" do
    v = RDF::Query::Variable.new("0")
    v.distinguished = false
    expect(v.to_sxp).to eq %q(??0)
  end
end

describe "RDF::Query::Pattern#to_sxp" do
  {
    RDF::Query::Pattern.new(RDF::URI("a"), RDF::URI("b"), RDF::URI("c")) => %q((triple <a> <b> <c>)),
    RDF::Query::Pattern.new(RDF::URI("a"), RDF::Query::Variable.new("b"), RDF::Literal.new("c")) =>
      %q((triple <a> ?b "c"))
  }.each_pair do |st, sxp|
    it "generates #{sxp} given #{st}" do
      expect(st.to_sxp).to eq sxp
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
    RDF::Query.new(graph_name: false) {} => %q((bgp)),
    RDF::Query.new(graph_name: RDF::URI("http://example.com/")) {
      pattern [RDF::URI("a"), RDF::URI("b"), RDF::URI("c")]
    } => %q((graph <http://example.com/> (bgp (triple <a> <b> <c>)))),
  }.each_pair do |st, sxp|
    it "generates #{sxp} given #{st.inspect}" do
      expect(st.to_sxp).to eq sxp
    end
  end

  context "prefix array with content" do
    let(:prefix) {
      [:prefix, [
        [:"foo:", RDF::URI("http://example.com/foo/")],
        [:"bar:", RDF::URI("http://example.com/bar#")],
        [:":", RDF::URI("http://empty/")]
      ]]
    }
    {
      (
        [RDF::URI("http://example.com/foo/a")]
      ) => %q(foo:a),
      (
        [RDF::Literal.new("2013-11-21", datatype: RDF::URI("http://example.com/foo/date"))]
      ) => %q("2013-11-21"^^foo:date),
    }.each_pair do |st, sxp|
      it "generates #{sxp} given #{st.inspect}" do
        expect((prefix + st).to_sxp).to eq "(prefix ((foo: <http://example.com/foo/>) (bar: <http://example.com/bar#>) (: <http://empty/>)) #{sxp})"
      end
    end
  end

  context "base array with content" do
    let(:base) {[:base, RDF::URI("http://example.com/foo/")]}
    {
      (
        [RDF::URI("http://example.com/foo/a")]
      ) => %q(<a>),
      (
        [RDF::Literal.new("2013-11-21", datatype: RDF::URI("http://example.com/foo/date"))]
      ) => %q("2013-11-21"^^<date>),
    }.each_pair do |st, sxp|
      it "generates #{sxp} given #{st.inspect}" do
        expect((base + st).to_sxp).to eq "(base <http://example.com/foo/> #{sxp})"
      end
    end
  end
end