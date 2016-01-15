#SXP.rb: S-Expressions for Ruby

This is a Ruby implementation of a universal [S-expression][] parser.

* <http://sxp.rubyforge.org/>
* <http://github.com/bendiken/sxp-ruby>

##Features

* Parses S-expressions in universal, [Scheme][], [Common Lisp][], or
  [SPARQL][] syntax.
* Adds a `#to_sxp` method to Ruby objects.
* Compatible with Ruby Ruby 2.x, Ruby 2.x, and JRuby 9+.

##Examples

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

    SXP::Reader::SPARQL.read %q((base <http://ar.to/>))  #=> [:base, RDF::URI('http://ar.to/')]

### Writing an SXP with formatting

    SXP::Generator.print([:and, true, false])   #=> (and #t #f)
  
##Documentation

* <http://sxp.rubyforge.org/>

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

Dependencies
------------

* [Ruby](http://ruby-lang.org/) (>= 1.9.3)
* [RDF.rb](http://rubygems.org/gems/rdf) (>= 1.1), only needed for SPARQL
  S-expressions

Installation
------------

The recommended installation method is via [RubyGems](http://rubygems.org/).
To install the latest official release of the SXP.rb gem, do:

    % [sudo] gem install sxp

Download
--------

To get a local working copy of the development repository, do:

    % git clone git://github.com/bendiken/sxp-ruby.git

Alternatively, you can download the latest development version as a tarball
as follows:

    % wget http://github.com/bendiken/sxp-ruby/tarball/master

Resources
---------

* <http://sxp.rubyforge.org/>
* <http://github.com/bendiken/sxp>
* <http://github.com/bendiken/sxp-ruby>
* <http://rubygems.org/gems/sxp>
* <http://rubyforge.org/projects/sxp/>
* <http://raa.ruby-lang.org/project/sxp>

Authors
-------

* [Arto Bendiken](https://github.com/bendiken) - <http://ar.to/>
* [Gregg Kellogg](http://github.com/gkellogg) - <http://kellogg-assoc.com/>

Contributors
------------

* [Ben Lavender](https://github.com/bhuga) - <http://bhuga.net/>

License
-------

SXP.rb is free and unencumbered public domain software. For more
information, see <http://unlicense.org/> or the accompanying UNLICENSE file.

[S-expression]: http://en.wikipedia.org/wiki/S-expression
[Scheme]:       http://scheme.info/
[Common Lisp]:  http://en.wikipedia.org/wiki/Common_Lisp
[SPARQL]:       http://openjena.org/wiki/SSE
[Backports]:    http://rubygems.org/gems/backports
