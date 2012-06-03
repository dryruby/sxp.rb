require File.join(File.dirname(__FILE__), 'spec_helper')

describe SXP::Generator do
  context ".string" do
    {
      "short sxp" => [
        [:bgp, [:triple, :s, :p, :o]],
        %{(bgp (triple s p o))\n}
      ],
      "long component" => [
        [:thing, [:string, "abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"]],
        %{(thing
 (string
  "abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
 )
)
}
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
   (named <data-g4.ttl>)
  )
  (union
   (bgp (triple ?s ?p ?o))
   (graph ?g (bgp (triple ?s ?p ?o)))
  )
 )
)
}
      ],
    }.each do |title, (input, expected)|
      it title do
        SXP::Generator.string(input).should == expected
      end
    end
  end
end
