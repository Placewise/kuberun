
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "kuberun/version"

Gem::Specification.new do |spec|
  spec.name          = "kuberun"
  spec.license       = "MIT"
  spec.version       = Kuberun::VERSION
  spec.authors       = ["kruczjak"]
  spec.email         = ["jakub.kruczek@boostcom.no"]

  spec.summary       = %q{CLI to run pods based on deployments}
  spec.description   = %q{CLI to run pods based on deployments}
  spec.homepage      = "https://boostcom.com"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "tty-color", "~> 0.4.2"
  spec.add_dependency "tty-command", "~> 0.8.0"
  spec.add_dependency "tty-config", "~> 0.2.0"
  spec.add_dependency "tty-cursor", "~> 0.5.0"
  spec.add_dependency "tty-editor", "~> 0.4.0"
  spec.add_dependency "tty-file", "~> 0.6.0"
  spec.add_dependency "tty-font", "~> 0.2.0"
  spec.add_dependency "tty-markdown", "~> 0.4.0"
  spec.add_dependency "tty-pager", "~> 0.11.0"
  spec.add_dependency "tty-platform", "~> 0.1.0"
  spec.add_dependency "tty-progressbar", "~> 0.15.0"
  spec.add_dependency "tty-prompt", "~> 0.16.1"
  spec.add_dependency "tty-screen", "~> 0.6.4"
  spec.add_dependency "tty-spinner", "~> 0.8.0"
  spec.add_dependency "tty-table", "~> 0.10.0"
  spec.add_dependency "tty-tree", "~> 0.1.0"
  spec.add_dependency "tty-which", "~> 0.3.0"
  spec.add_dependency "pastel", "~> 0.7.2"
  spec.add_dependency "thor", "~> 0.20.0"

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
