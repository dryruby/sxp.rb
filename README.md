# SXP.rb: S-Expressions for Ruby

This is a Ruby implementation of a universal [S-expression][] parser.

[![Gem Version](https://badge.fury.io/rb/sxp.png)](https:/badge.fury.io/rb/sxp)
[![Build Status](https://github.com/dryruby/sxp.rb/workflows/CI/badge.svg?branch=develop)](https://github.com/dryruby/sxp.rb/actions?query=workflow%3ACI)
[![Coverage Status](https://coveralls.io/repos/dryruby/sxp.rb/badge.svg?branch=develop)](https://coveralls.io/r/dryruby/sxp.rb?branch=develop)

## Features

* Parses S-expressions in universal, [Scheme][], [Common Lisp][], or
  [SPARQL][] syntax.
* Adds a `#to_sxp` method to Ruby objects.
* Compatible with Ruby >= 2.4, Rubinius >= 3.0, and JRuby 9+.

## Examples

    require 'sxp'

### Parsing basic S-expressions

    SXP.read "(* 6 7)"  #=> [:*, 6, 7]

    SXP.read <<-EOF
      (define (fact n)
        (if (= n 0)
            1
            (* n (fact (- n 1)))))
    EOF
    
    #=> [:define, [:fact, :n],
          [:if, [:"=", :n, 0],
                1,
                [:*, :n, [:fact, [:-, :n, 1]]]]]

### Parsing Scheme S-expressions

    SXP::Reader::Scheme.read %q((and #t #f))             #=> [:and, true, false]

### Parsing Common Lisp S-expressions

    SXP::Reader::CommonLisp.read %q((or t nil))          #=> [:or, true, nil]

### Parsing SPARQL S-expressions

    require 'rdf'

    SXP::Reader::SPARQL.read %q((base <https://ar.to/>))  #=> [:base, RDF::URI('https://ar.to/')]

### Writing an SXP with formatting

    SXP::Generator.print([:and, true, false])   #=> (and #t #f)
  
## Documentation

* Full documentation available on [RubyDoc](https:/rubydoc.info/gems/sxp/file/README.md)

* {SXP}

### Parsing SXP
  * {SXP::Reader}
    * {SXP::Reader::Basic}
      * {SXP::Reader::CommonLisp}
      * {SXP::Reader::Extended}
        * {SXP::Reader::Scheme}
        * {SXP::Reader::SPARQL}

### Manipulating SXP
  * {SXP::Pair}
    * {SXP::List}

### Generating SXP
  * {SXP::Generator}

#  Dependencies

* [Ruby](https:/ruby-lang.org/) (>= 2.4)
* [RDF.rb](https:/rubygems.org/gems/rdf) (~> 3.1), only needed for SPARQL
  S-expressions

#  Installation

The recommended installation method is via [RubyGems](https:/rubygems.org/).
To install the latest official release of the SXP.rb gem, do:

    % [sudo] gem install sxp

## Download

To get a local working copy of the development repository, do:

    % git clone git://github.com/dryruby/sxp.rb.git

Alternatively, you can download the latest development version as a tarball
as follows:

    % wget https:/github.com/dryruby/sxp.rb/tarball/master

## Resources

* <https://rubydoc.info/gems/sxp.rb>
* <https://github.com/dryruby/sxp.rb>
* <https://rubygems.org/gems/sxp.rb>

## Authors

* [Arto Bendiken](https://github.com/artob) - <https://ar.to/>
* [Gregg Kellogg](https://github.com/gkellogg) - <https://greggkellogg.net/>

## Contributors

* [Ben Lavender](https://github.com/bhuga) - <https://bhuga.net/>

## Contributing
This repository uses [Git Flow](https://github.com/nvie/gitflow) to mange development and release activity. All submissions _must_ be on a feature branch based on the _develop_ branch to ease staging and integration.

* Do your best to adhere to the existing coding conventions and idioms.
* Don't use hard tabs, and don't leave trailing whitespace on any line.
* Do document every method you add using [YARD][] annotations. Read the
  [tutorial][YARD-GS] or just look at the existing code for examples.
* Don't touch the `.gemspec`, `VERSION` or `AUTHORS` files. If you need to
  change them, do so on your private branch only.
* Do feel free to add yourself to the `CREDITS` file and the corresponding
  list in the the `README`. Alphabetical order applies.
* Do note that in order for us to merge any non-trivial changes (as a rule
  of thumb, additions larger than about 15 lines of code), we need an
  explicit [public domain dedication][PDD] on record from you,
  which you will be asked to agree to on the first commit to a repo within the organization.

## License

SXP.rb is free and unencumbered public domain software. For more
information, see <https://unlicense.org/> or the accompanying UNLICENSE file.

[S-expression]: https://en.wikipedia.org/wiki/S-expression
[Scheme]:       https://scheme.info/
[Common Lisp]:  https://en.wikipedia.org/wiki/Common_Lisp
[SPARQL]:       https://jena.apache.org/documentation/notes/sse.html
[YARD]:         https://yardoc.org/
[YARD-GS]:      https://rubydoc.info/docs/yard/file/docs/GettingStarted.md
[PDD]:          https://lists.w3.org/Archives/Public/public-rdf-ruby/2010May/0013.html
