require File.join(File.dirname(__FILE__), 'spec_helper')

describe SXP::Generator do
  context ".string" do
    {
      "short sxp":[
        [:bgp, [:triple, :s, :p, :o]],
        %{(bgp (triple s p o))\n}
      ],
      "long component":[
        [:thing, [:string, "abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"]],
        %{(thing
           (string
            "abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
           ))
          }.gsub(/^          /, '')
      ],
      "SPARQL":[
        [:prefix,
          [[:":", RDF::URI("http://example/")]],
          [:dataset,
            [RDF::URI("data-g1.ttl"),
              [:named, RDF::URI("data-g1.ttl")],
              [:named, RDF::URI("data-g2.ttl")],
              [:named, RDF::URI("data-g3.ttl")],
              [:named, RDF::URI("data-g4.ttl")]],
            [:union,
              [:bgp,[:triple, :"?s", :"?p", :"?o"]],
              [:graph, :"?g", [:bgp, [:triple, :"?s", :"?p", :"?o"]]]]]],
        %{(prefix
           ((: <http://example/>))
           (dataset
            (<data-g1.ttl>
             (named <data-g1.ttl>)
             (named <data-g2.ttl>)
             (named <data-g3.ttl>)
             (named <data-g4.ttl>))
            (union (bgp (triple ?s ?p ?o)) (graph ?g (bgp (triple ?s ?p ?o))))) )
          }.gsub(/^          /, '')
      ],
      "EBNF":[
        [[:rule, :empty, "abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"],
         [:rule, :ebnf, "abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"]],
        %q{(
           (rule empty
            "abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
           )
           (rule ebnf
            "abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
           ))
          }.gsub(/^          /, '')
      ],
      "SPARQL Terms": [
        [:bgp,
          [:triple, RDF::URI(:a), RDF::URI(:b), RDF::Literal("")],
          [:triple, RDF::URI(:a), RDF::URI(:b), RDF::Literal("hello")],
          [:triple, RDF::URI(:a), RDF::URI(:b), RDF::Literal("hello", language: :en)],
          [:triple, RDF::URI(:a), RDF::URI(:b), RDF::Literal(true)],
          [:triple, RDF::URI(:a), RDF::URI(:b), RDF::Literal(false)],
          [:triple, RDF::URI(:a), RDF::URI(:b), RDF::Literal(123)],
          [:triple, RDF::URI(:a), RDF::URI(:b), RDF::Literal(-18)],
          [:triple, RDF::URI(:a), RDF::URI(:b), RDF::Literal::Decimal.new(123.0)],
          [:triple, RDF::URI(:a), RDF::URI(:b), RDF::Literal::Double.new(1.0e0)],
          [:triple, RDF::URI(:a), RDF::URI(:b), RDF::Literal("lex", datatype: 'http://example.org/thing')],
          [:triple, RDF::URI(:a), RDF::URI(:b), RDF::Query::Variable.new(:x)],
        ],
        %q{(bgp
            (triple <a> <b> "")
            (triple <a> <b> "hello")
            (triple <a> <b> "hello"@en)
            (triple <a> <b> true)
            (triple <a> <b> false)
            (triple <a> <b> 123)
            (triple <a> <b> -18)
            (triple <a> <b> 123.0)
            (triple <a> <b> 1.0e0)
            (triple <a> <b> "lex"^^<http://example.org/thing>)
            (triple <a> <b> ?x))
           }.gsub(/^           /, '')
      ],
      "SPARQL base": [
        [:base, RDF::URI("http://example.com/"), RDF::URI("http://example.com/a")],
        %q{(base <http://example.com/> <a>)
        }.gsub(/^        /, '')
      ],
      "issue 20": [
        [:prefix,
         [[:"wdt:", RDF::URI("http://www.wikidata.org/prop/direct/")],
          [:"wd:", RDF::URI("http://www.wikidata.org/entity/")]],
         [:bgp,
          [:triple,
           RDF::Query::Variable.new(:person),
           RDF::URI("http://www.wikidata.org/prop/direct/P31"),
           RDF::URI("http://www.wikidata.org/entity/Q5")]]],
        %q{(prefix
        (
         (wdt: <http://www.wikidata.org/prop/direct/>)
         (wd: <http://www.wikidata.org/entity/>))
        (bgp (triple ?person wdt:P31 wd:Q5)))
       }.gsub(/^       /, '')
      ]
    }.each do |title, (input, expected)|
      it title do
        expect(SXP::Generator.string(input)).to eq expected
      end
    end
  end
end
