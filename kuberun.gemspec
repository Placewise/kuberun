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

  spec.add_dependency 'pastel', '~> 0.8.0'
  spec.add_dependency 'thor', '~> 1.2.1'
  spec.add_dependency 'tty-command', '~> 0.10.1'
  spec.add_dependency 'tty-cursor', '~> 0.7.1'
  spec.add_dependency 'tty-editor', '~> 0.7.0'
  spec.add_dependency 'tty-file', '~> 0.10.0'
  spec.add_dependency 'tty-pager', '~> 0.14.0'
  spec.add_dependency 'tty-platform', '~> 0.3.0'
  spec.add_dependency 'tty-prompt', '~> 0.23.1'
  spec.add_dependency 'tty-screen', '~> 0.8.1'
  spec.add_dependency 'tty-which', '~> 0.5.0'

  spec.add_development_dependency 'bundler', '~> 2'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 0.58.0'
end
