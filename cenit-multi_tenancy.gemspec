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
  spec.required_ruby_version = '>= 3.2.0'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 2.4'
  spec.add_development_dependency 'rake', '>= 13.0'

  spec.add_runtime_dependency 'cenit-config'
  spec.add_runtime_dependency 'glebtv_mongoid_userstamp', '>= 0.10.0'
  spec.add_runtime_dependency 'mongoid', '>= 8.0', '< 9.0'
end
