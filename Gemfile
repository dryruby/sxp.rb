source 'https://rubygems.org'

gemspec

gem "rdf", git: "git://github.com/ruby-rdf/rdf.git", branch: "develop"

group :debug do
  gem "byebug", platform: :mri
  gem 'awesome_print',    github: 'akshaymohite/awesome_print'
end

group :development, :test do
  gem 'simplecov',  platforms: :mri
  gem 'coveralls',  '~> 0.8', platforms: :mri
end
