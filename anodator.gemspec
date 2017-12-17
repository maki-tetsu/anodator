# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "anodator/version"

Gem::Specification.new do |spec|
  spec.name          = "anodator"
  spec.version       = Anodator::VERSION
  spec.authors       = ["Tetsuhisa MAKINO"]
  spec.email         = ["tim.makino at gmail.com"]

  spec.summary       = %q{anodator is Anonymous Data Validator.}
  spec.homepage      = "https://github.com/maki-tetsu/anodator"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = "~> 2.4"

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
