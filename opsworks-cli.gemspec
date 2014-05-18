# encoding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'English'
require 'opsworks/cli/version'

Gem::Specification.new do |spec|
  spec.name          = 'opsworks-cli'
  spec.version       = OpsWorks::CLI::VERSION
  spec.authors       = ['Frank Macreery']
  spec.email         = ['frank@macreery.com']
  spec.description   = %q(OpsWorks CLI)
  spec.summary       = %q(Alternative CLI for Amazon OpsWorks)
  spec.homepage      = 'https://github.com/aptible/opsworks-cli'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($RS)
  spec.test_files    = spec.files.grep(/^spec\//)
  spec.require_paths = ['lib']

  spec.add_dependency 'thor'
  spec.add_dependency 'aws-sdk'

  spec.add_development_dependency 'aws-keychain-util'
  spec.add_development_dependency 'bundler', '~> 1.5'
  spec.add_development_dependency 'aptible-tasks'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '~> 2.0'
  spec.add_development_dependency 'pry'
end
