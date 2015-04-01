# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'master_manipulator/version'

Gem::Specification.new do |spec|
  spec.name          = "master_manipulator"
  spec.version       = MasterManipulator::Version::STRING
  spec.authors       = ["Puppetlabs"]
  spec.email         = ["qa@puppetlabs.com"]
  spec.summary       = %q{Puppetlabs testing library for Beaker}
  spec.description   = %q{Puppetlabs testing library for controlling a Puppet Master}
  spec.homepage      = "https://github.com/puppetlabs/master_manipulator"
  spec.license       = "Apache2"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  #Development dependencies
  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'pry', '~> 0.9.12'

  #Documentation dependencies
  spec.add_development_dependency 'yard', '~> 0'
  spec.add_development_dependency 'markdown', '~> 0'

  #Run time dependencies
  spec.add_runtime_dependency 'beaker', '~> 2.7', '>= 2.7.0'
end
