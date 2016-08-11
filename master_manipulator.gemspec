# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'master_manipulator/version'

Gem::Specification.new do |spec|
  spec.name          = 'master_manipulator'
  spec.version       = MasterManipulator::Version::STRING
  spec.authors       = ['Puppet Labs']
  spec.email         = ['qa@puppetlabs.com']
  spec.summary       = 'Puppet Labs testing library for controlling a Puppet Master'
  spec.description   = 'This Gem extends the Beaker DSL for the purpose of changing things on a Puppet Master.'
  spec.homepage      = 'https://github.com/puppetlabs/master_manipulator'
  spec.license       = 'Apache-2.0'
  spec.files         = Dir['[A-Z]*[^~]'] + Dir['lib/**/*.rb'] + Dir['spec/*']
  spec.test_files    = Dir['spec/*']

  # Development dependencies
  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'pry', '~> 0.9.12'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '>= 3.0.0'
  spec.add_development_dependency 'simplecov'

  # Documentation dependencies
  spec.add_development_dependency 'yard', '~> 0'
  spec.add_development_dependency 'markdown', '~> 0'

  # Run time dependencies
  spec.add_runtime_dependency 'beaker', '~> 2.7', '>= 2.7.0'
  spec.add_runtime_dependency 'multi_json'

end
