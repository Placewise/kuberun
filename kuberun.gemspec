# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kuberun/version'

Gem::Specification.new do |spec|
  spec.name          = 'kuberun'
  spec.license       = 'MIT'
  spec.version       = Kuberun::VERSION
  spec.authors       = ['kruczjak']
  spec.email         = ['jakub.kruczek@boostcom.no']

  spec.summary       = 'CLI to run pods based on deployments'
  spec.description   = 'CLI to run pods based on deployments'
  spec.homepage      = 'https://boostcom.com'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '~> 3.0'

  spec.add_dependency 'pastel'
  spec.add_dependency 'thor'
  spec.add_dependency 'tty-command'
  spec.add_dependency 'tty-cursor'
  spec.add_dependency 'tty-editor'
  spec.add_dependency 'tty-file'
  spec.add_dependency 'tty-pager'
  spec.add_dependency 'tty-platform'
  spec.add_dependency 'tty-prompt'
  spec.add_dependency 'tty-screen'
  spec.add_dependency 'tty-which'

  spec.add_development_dependency 'base64'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rubocop'
end
