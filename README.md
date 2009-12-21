SXP.rb: SXP for Ruby
====================

This is the Ruby reference implementation of the SXP data interchange
format.

* <http://sxp.rubyforge.org/>
* <http://github.com/bendiken/sxp-ruby>

### About SXP

SXP is a data interchange format based on S-expressions, the simplest and
most versatile known means of representing complex data structures such as
lists, trees and graphs.

* <http://sxp.cc/>
* <http://en.wikipedia.org/wiki/S-expression>

Features
--------

* Parses S-expressions in SXP format.
* Adds a `#to_sxp` method to Ruby objects.

Examples
--------

    require 'sxp'

### Parsing S-expressions

    SXP.read "(+ 1 2)"
    
    => [:+, 1, 2]


    SXP.read <<-EOF
      (define (fact n)
        (if (= n 0)
            1
            (* n (fact (- n 1)))))
    EOF
    
    => [:define, [:fact, :n],
         [:if, [:"=", :n, 0],
               1,
               [:*, :n, [:fact, [:-, :n, 1]]]]]

Documentation
-------------

* <http://sxp.rubyforge.org/>

Download
--------

To get a local working copy of the development repository, do:

    % git clone git://github.com/bendiken/sxp-ruby.git

Alternatively, you can download the latest development version as a tarball
as follows:

    % wget http://github.com/bendiken/sxp-ruby/tarball/master

Installation
------------

The recommended installation method is via RubyGems. To install the latest
official release from Gemcutter, do:

    % [sudo] gem install sxp

Resources
---------

* <http://sxp.rubyforge.org/>
* <http://github.com/bendiken/sxp>
* <http://github.com/bendiken/sxp-ruby>
* <http://gemcutter.org/gems/sxp>
* <http://rubyforge.org/projects/sxp/>
* <http://raa.ruby-lang.org/project/sxp>

Author
------

* [Arto Bendiken](mailto:arto.bendiken@gmail.com) - <http://ar.to/>

License
-------

SXP.rb is free and unencumbered public domain software. For more
information, see <http://unlicense.org/> or the accompanying UNLICENSE file.
