require File.join(File.dirname(__FILE__), 'spec_helper')

describe SXP::Generator do
  context ".string" do
    {
      "short sxp" => [
        [:bgp, [:triple, :s, :p, :o]],
        %{(bgp (triple s p o))\n}
      ],
      "long component" => [
        [:thing, [:string, "abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"]],
        %{(thing
           (string
            "abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
           ))
          }.gsub(/^          /, '')
      ],
      "SPARQL" => [
        [:prefix,
          [[:":", :"<http://example/>"]],
          [:dataset,
            [:"<data-g1.ttl>",
              [:named, :"<data-g1.ttl>"],
              [:named, :"<data-g2.ttl>"],
              [:named, :"<data-g3.ttl>"],
              [:named, :"<data-g4.ttl>"]],
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
      "EBNF" => [
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
      ]
    }.each do |title, (input, expected)|
      it title do
        expect(SXP::Generator.string(input)).to eq expected
      end
    end
  end
end
