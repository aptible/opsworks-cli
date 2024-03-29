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
  spec.description   = 'OpsWorks CLI'
  spec.summary       = 'Alternative CLI for Amazon OpsWorks'
  spec.homepage      = 'https://github.com/aptible/opsworks-cli'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($RS)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^spec/})
  spec.require_paths = ['lib']

  spec.add_dependency 'activesupport'
  spec.add_dependency 'aws-sdk-opsworks', '~> 1.30.0'
  spec.add_dependency 'jsonpath', '1.0.5'
  spec.add_dependency 'thor'

  spec.add_development_dependency 'aptible-tasks', '~> 0.5.9'
  spec.add_development_dependency 'bundler', '< 2'
  spec.add_development_dependency 'fabrication', '~> 2.16.0'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'timecop', '~> 0.9'
end
