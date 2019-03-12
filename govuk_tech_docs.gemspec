# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "govuk_tech_docs/version"

Gem::Specification.new do |spec|
  spec.name          = "govuk_tech_docs"
  spec.version       = GovukTechDocs::VERSION
  spec.authors       = ["Government Digital Service"]
  spec.email         = ["govuk-dev@digital.cabinet-office.gov.uk"]

  spec.summary       = %q{Gem to distribute the GOV.UK Tech Docs Template}
  spec.description   = %q{Gem to distribute the GOV.UK Tech Docs Template. See https://github.com/alphagov/tech-docs-gem for the project.}
  spec.homepage      = "https://github.com/alphagov/tech-docs-gem"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport"
  spec.add_dependency "chronic", "~> 0.10.2"
  spec.add_dependency "middleman", "~> 4.0"
  spec.add_dependency "middleman-autoprefixer", "~> 2.7.0"
  spec.add_dependency "middleman-compass", ">= 4.0.0"
  spec.add_dependency "middleman-livereload"
  spec.add_dependency "middleman-sprockets", "~> 4.0.0"
  spec.add_dependency "middleman-syntax", "~> 3.0.0"
  spec.add_dependency "middleman-search-gds"
  spec.add_dependency "nokogiri"
  spec.add_dependency "redcarpet", "~> 3.3.2"
  spec.add_dependency "openapi3_parser"
  spec.add_dependency "pry"


  spec.add_development_dependency "bundler", "~> 2.0.1"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "capybara", "~> 2.18.0"
  spec.add_development_dependency "govuk-lint", "~> 3.7.0"
  spec.add_development_dependency "jasmine", "~> 3.1.0"
  spec.add_development_dependency "rspec", "~> 3.7.0"
  spec.add_development_dependency "byebug"
end
