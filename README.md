# SXP.rb: S-Expressions for Ruby

This is a Ruby implementation of a universal [S-expression][] parser.

[![Gem Version](https://badge.fury.io/rb/sxp.svg)](https:/badge.fury.io/rb/sxp)
[![Build Status](https://github.com/dryruby/sxp.rb/workflows/CI/badge.svg?branch=develop)](https://github.com/dryruby/sxp.rb/actions?query=workflow%3ACI)
[![Coverage Status](https://coveralls.io/repos/dryruby/sxp.rb/badge.svg?branch=develop)](https://coveralls.io/r/dryruby/sxp.rb?branch=develop)

## Features

* Parses S-expressions in universal, [Scheme][], [Common Lisp][], or
  [SPARQL][] syntax.
* Adds a `#to_sxp` method to Ruby objects.
* Compatible with Ruby >= 3.0, Rubinius >= 3.0, and JRuby 9+.

## Basic syntax

S-Expressions derive from LISP, and include some basic datatypes common to all variants:

<dl>
  <dt>Pairs</dt>
  <dd>Of the form <code>(2 . 3)</code></dd>
  <dt>Lists</dt>
  <dd>Of the form <code>(1 (2 3))</code></dd>
  <dt>Symbols</dt>
  <dd>Of the form <code>with-hyphen ?@!$ a\ symbol\ with\ spaces</code></dd>
  <dt>Strings</dt>
  <dd>Of the form <code>"Hello, world!"</code> or <code>'Hello, world!'</code><br/>
      Strings may include the following special characters:
      <ul>
        <li><code>\b</code> &mdash; Backspace</li>
        <li><code>\f</code> &mdash; Form Feed</li>
        <li><code>\n</code> &mdash; New Line</li>
        <li><code>\r</code> &mdash; Carriage Return</li>
        <li><code>\t</code> &mdash; Horizontal Tab</li>
        <li><code>\u<i>xxxx</i></code> &mdash; 2-byte Unicode character escape</li>
        <li><code>\U<i>xxxxxxxx</i></code> &mdash; 4-byte Unicode character escape</li>
        <li><code>\"</code> &mdash; Double-quote character</li>
        <li><code>\'</code> &mdash; Single-quote character</li>
        <li><code>\\</code> &mdash; Backspace</li>
      </ul>
      Additionally, any other character may follow <code>\</code>, representing the character itself.
  </dd>
  <dt>Characters</dt>
  <dd>Of the form <code>...</code></dd>
  <dt>Integers</dt>
  <dd>Of the form <code>-9876543210</code></dd>
  <dt>Floating-point numbers</dt>
  <dd>Of the form <code>-0.0 6.28318 6.022e23</code></dd>
  <dt>Rationals</dt>
  <dd>Of the form <code>1/3</code></dd>
</dl>

Additionally, variation-specific formats support additional datatypes:

### Scheme

In addition to the standard datatypes, the Scheme dialect supports the following:

<dl>
  <dt>Lists</dt>
  <dd>In addition to <code>( ... )</code>, a square bracket pair may be used for reading lists of the form <code>[ ... ]</code>.
  </dd>
  <dt>Comments</dt>
  <dd>A comment starts with <code>;</code> and continues to the end of the line.
  <dt>Sharp character sequences</dt>
  <dd>Such as <code>#t</code>, <code>#n</code>, and <code>#xXXX</code>.<br>
    <ul>
        <li><code>#n</code> &mdash; Null</li>
        <li><code>#f</code> &mdash; False</li>
        <li><code>#t</code> &mdash; True</li>
        <li><code>#b<i>BBB</i></code> &mdash; Binary number</li>
        <li><code>#o<i>OOO</i></code> &mdash; Octal number</li>
        <li><code>#d<i>DDD</i></code> &mdash; Decimal number</li>
        <li><code>#x<i>XXX</i></code> &mdash; Hexadecimal number</li>
        <li><code>#\<i>C</i></code> &mdash; A single Unicode character</li>
        <li><code>#\space</code> &mdash; A space character</li>
        <li><code>#\newline</code> &mdash; A newline character</li>
        <li><code>#;</code> &mdash; Skipped character</li>
        <li><code>#!</code> &mdash; Skipped to end of line</li>
    </ul>
  </dd>
</dl>

### Common Lisp

In addition to the standard datatypes, the Common Lisp dialect supports the following:

<dl>
  <dt>Comments</dt>
  <dd>A comment starts with <code>;</code> and continues to the end of the line.
  <dt>Symbols</dt>
  <dd>In addition to base symbols, any character sequence delimited by <code>|</code> is treated as a symbol.</dd>
  <dt>Sharp character sequences</dt>
  <dd>Such as <code>#t</code>, <code>#n</code>, and <code>#xXXX</code>.<br>
    <ul>
        <li><code>#b<i>BBB</i></code> &mdash; Binary number</li>
        <li><code>#o<i>OOO</i></code> &mdash; Octal number</li>
        <li><code>#x<i>XXX</i></code> &mdash; Hexadecimal number</li>
        <li><code>#C</code> &mdash; A single Unicode character</li>
        <li><code>#\newline</code> &mdash; A newline character</li>
        <li><code>#\space</code> &mdash; A space character</li>
        <li><code>#\backspace</code> &mdash; A backspace character</li>
        <li><code>#\tab</code> &mdash; A tab character</li>
        <li><code>#\linefeed</code> &mdash; A linefeed character</li>
        <li><code>#\page</code> &mdash; A page feed character</li>
        <li><code>#\return</code> &mdash; A carriage return character</li>
        <li><code>#\rubout</code> &mdash; A rubout character</li>
        <li><code>#'<i>function</i></code> &mdash; A function definition</li>
    </ul>
  </dd>
</dl>

### SPARQL/RDF

In addition to the standard datatypes, the SPARQL dialect supports the following:

<dl>
  <dt>Lists</dt>
  <dd>In addition to <code>( ... )</code>, a square bracket pair may be used for reading lists of the form <code>[ ... ]</code>.
  </dd>
  <dt>Comments</dt>
  <dd>A comment starts with <code>#</code> or <code>;</code> and continues to the end of the line.
  <dt>Literals</dt>
  <dd>Strings are interpreted as an RDF Literal with datatype <code>xsd:string</code>. It can be followed by <code>@<i>lang</i></code> to create a language-tagged string, or <code>^^<i>IRI</i></code> to create a datatyped-literal. Examples:
    <ul>
      <li><code>"a plain literal"</code></li>
      <li><code>'another plain literal'</code></li>
      <li><code>"a literal with a language"@en</code></li>
      <li><code>"a typed literal"^^&lt;http://example/></code></li>
      <li><code>"a typed literal with a PNAME"^^xsd:string</code></li>
    </ul>
  </dd>
  <dt>IRIs</dt>
  <dd>An IRI is formed as in SPARQL, either enclosed by <code>&lt;...></code>, or having the form of a <code>PNAME</code>. If a <var>base iri</var> is defined in a containing <var>base</var> expression, IRIs using the <code>&lt;...></code> are resolved against that base iri. If the <code>PNAME</code> form is used, the prefix must be defined in a containing <var>prefix</var> expression. Examples:
    <ul>
      <li><code>&lt;http://example/foo></code></li>
      <li><code>(base &lthttp://example.com> &lt;foo>)</code></li>
      <li><code>(prefix ((foo: &lt;http://example.com/>)) foo:bar)</code></li>
      <li><code>a</code> # synonym for rdf:type</li>
    </ul>
  </dd>
  <dt>Blank Nodes</dt>
  <dd>An blank node is formed as in SPARQL. Examples:
    <ul>
      <li><code>_:</code></li>
      <li><code>_:id</code></li>
    </ul>
  </dd>
  <dt>Variables</dt>
  <dd>A SPARQL variable is defined using either <code>?</code> or <code>$</code> prefixes, as in SPARQL. Examples:
    <ul>
      <li><code>?var</code></li>
      <li><code>$var</code></li>
    </ul>
  </dd>
  <dt>Numbers and booleans</dt>
  <dd>As with SPARQL. Examples:
    <ul>
      <li>true, false</li>
      <li>123, -18</li>
      <li>123.0, 456.</li>
      <li>1.0e0, 1.0E+6</li>
    </ul>
  </dd>
</dl>

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

* Full documentation available on [RubyDoc](https://dryruby.github.io/sxp)

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

* [Ruby](https:/ruby-lang.org/) (>= 3.0)
* [RDF.rb](https:/rubygems.org/gems/rdf) (~> 3.3), only needed for SPARQL
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

## Change Log

See [Release Notes on GitHub](https://github.com/dryruby/sxp.rb/releases)

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
