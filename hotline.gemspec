# frozen_string_literal: true

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "hotline/version"

Gem::Specification.new do |spec|
  spec.name = "hotline"
  spec.version = Hotline::VERSION
  spec.authors = ["Bryce Mecum"]
  spec.email = ["petridish@gmail.com"]

  spec.summary = "Ruby gem for the Hotline protocol"
  spec.description = "An implementation of the Hotline protocols, currently just the tracker client."
  spec.homepage = "https://github.com/amoeba/hotline"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.3.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/amoeba/hotline"
  spec.metadata["changelog_uri"] = "https://github.com/amoeba/hotline/releases"

  spec.files = Dir["lib/**/*", "bin/tracker_client", "LICENSE.txt", "README.md"]
  spec.bindir = "bin"
  spec.executables << "tracker_client"
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "minitest", "~> 5.14"
  spec.add_development_dependency "standard", "~> 1.0"

  spec.add_runtime_dependency "bindata", "~> 2.0"
end
