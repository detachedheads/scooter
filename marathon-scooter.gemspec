# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'scooter/version'

Gem::Specification.new do |spec|
  spec.name                   = 'marathon-scooter'
  spec.version                = Scooter::Version::STRING.dup
  spec.authors                = ['Yieldbot']
  spec.email                  = ['devops@yieldbot.com']
  spec.summary                = 'Opinionated synchronization of Marathon jobs from JSON files.'
  spec.description            = 'Opinionated synchronization of Marathon jobs from JSON files.'
  spec.homepage               = 'https://github.com/yieldbot/scooter'
  spec.license                = 'MIT'
  spec.platform               = Gem::Platform::RUBY
  spec.required_ruby_version  = '>= 2.0'

  spec.bindir                 = 'bin'
  spec.files                  = Dir['{bin}/**/*', '{lib,spec}/**/*.rb', 'LICENSE', '*.md']
  spec.executables            = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files             = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths          = %w(lib)

  spec.add_dependency 'colorize',           '~> 0.7'
  spec.add_dependency 'gli',                '~> 2.12'
  spec.add_dependency 'log4r',              '~> 1.1.10'
  spec.add_dependency 'marathon-api',       '~> 1.2.5'
  
  spec.add_development_dependency 'bundler',            '~> 1.7'
  spec.add_development_dependency 'rake',               '~> 10.0'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rspec-mocks'
  spec.add_development_dependency 'rubocop',            '~> 0.26.1'
  spec.add_development_dependency 'yard',            '~> 0.8'
end
