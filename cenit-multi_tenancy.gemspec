# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cenit/multi_tenancy/version'

Gem::Specification.new do |spec|
  spec.name          = 'cenit-multi_tenancy'
  spec.version       = Cenit::MultiTenancy::VERSION
  spec.authors       = ['Maikel Arcia']
  spec.email         = ['macarci@gmail.com']

  spec.summary       = %q{Provides multi-tenancy functionality to store records using Mongoid.}
  spec.homepage      = 'https://cenit.io'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.8'
  spec.add_development_dependency 'rake', '~> 10.0'

  spec.add_runtime_dependency 'cenit-config'
  spec.add_runtime_dependency 'glebtv_mongoid_userstamp', '>= 0.6.0'
  spec.add_runtime_dependency 'mongoid', '>= 5.0.1'
end
