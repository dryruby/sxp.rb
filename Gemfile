source 'https://rubygems.org'

gemspec

gem "rdf",            :git => "git://github.com/ruby-rdf/rdf.git", :branch => "develop"

group :debug do
  gem "wirble"
  gem "debugger", :platforms => :mri_19
  gem "ruby-debug", :platforms => [:jruby]
end

platforms :rbx do
  gem 'rubysl', '~> 2.0'
  gem 'rubinius', '~> 2.0'
end
