# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gls_track_and_trace/version'

Gem::Specification.new do |spec|
  spec.name          = "gls_track_and_trace"
  spec.version       = GlsTrackAndTrace::VERSION
  spec.authors       = ["Jan Svoboda"]
  spec.email         = ["jan@mluv.cz"]
  spec.summary       = %q{Ruby client library for GLS Europe Track&Trace SOAP API.}
  spec.description   = %q{Ruby client library for GLS Europe Track&Trace SOAP API.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 1.9"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"

  spec.add_development_dependency "minitest", "~> 5.4.2"
end
