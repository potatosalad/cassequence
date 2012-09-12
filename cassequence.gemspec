# -*- encoding: utf-8 -*-
require File.expand_path('../lib/cassequence/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["lyon"]
  gem.email         = ["lyondhill@gmail.com"]
  gem.description   = %q{cassandra sequence querier}
  gem.summary       = %q{This is a cassandra sequence querier. The data needs to be in a very specific format.}
  gem.homepage      = "http://www.google.com"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "cassequence"
  gem.require_paths = ["lib"]
  gem.version       = Cassequence::VERSION

  gem.add_dependency 'cassandra'
  gem.add_dependency 'thrift_client', '~> 0.8.0'
  gem.add_dependency 'oj'
  gem.add_dependency 'multi_json'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'simplecov'
  gem.add_dependency 'pry'


end
