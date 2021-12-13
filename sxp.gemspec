#!/usr/bin/env ruby -rubygems
# -*- encoding: utf-8 -*-

Gem::Specification.new do |gem|
  gem.version            = File.read('VERSION').chomp
  gem.date               = File.mtime('VERSION').strftime('%Y-%m-%d')

  gem.name               = 'sxp'
  gem.homepage           = 'https://github.com/dryruby/sxp/'
  gem.license            = 'Unlicense'
  gem.summary            = 'A pure-Ruby implementation of a universal S-expression parser.'
  gem.description        = 'Universal S-expression parser with specific support for Common Lisp, Scheme, and RDF/SPARQL'

  gem.author             = ['Arto Bendiken', 'Gregg Kellogg']
  gem.email              = ['arto@bendiken.net', 'gregg@greggkellogg.net']

  gem.platform           = Gem::Platform::RUBY
  gem.files              = %w(AUTHORS CREDITS README.md UNLICENSE VERSION) + Dir.glob('bin/*.rb') + Dir.glob('lib/**/*.rb')
  gem.bindir             = %q(bin)
  gem.executables        = %w(sxp2rdf sxp2json sxp2xml sxp2yaml)
  gem.require_paths      = %w(lib)

  gem.required_ruby_version      = '>= 2.6'
  gem.requirements               = []
  gem.add_development_dependency 'rspec', '~> 3.10'
  gem.add_development_dependency 'yard' , '~> 0.9'
  gem.add_runtime_dependency     'rdf',   '~> 3.2'

  gem.post_install_message       = nil
end
