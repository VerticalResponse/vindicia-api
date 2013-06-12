# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'vindicia/version'

Gem::Specification.new do |gem|
  gem.name          = 'vindicia-api'
  gem.version       = Vindicia::VERSION
  gem.authors       = ['Tom Quackenbush', 'Victor Garro']
  gem.email         = ['tquackenbush@agoragames.com', 'vgarro@verticalresponse.com']
  gem.homepage      = 'https://github.com/agoragames/vindicia-api'
  gem.summary       = %q{A wrapper for creating queries to the Vindicia CashBox API}
  gem.description   = %q{This gem provides an interface with Vindicia API in which objects are retruned as hashes}

  gem.rubyforge_project = 'vindicia-api'

  gem.files         = Dir['CHANGELOG.md', 'LICENSE.txt', 'README.rdoc', 'Gemfile*', 'Rakefile',
                          'vindicia-api.gemspec', 'spec/**/*', 'lib/**/*']

  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_dependency('savon', '~> 1.2.0')
  gem.add_dependency('activesupport')

  gem.add_development_dependency('rake')
  gem.add_development_dependency('mocha')
  gem.add_development_dependency('rspec')
  gem.add_development_dependency('rr')
end
