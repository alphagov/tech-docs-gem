require "English"

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "govuk_tech_docs/version"

`npm ci`
abort "npm ci failed" unless $CHILD_STATUS.success?

unless File.exist?("node_modules/govuk-frontend/dist/govuk/_base.scss")
  abort "govuk-frontend npm package not installed"
end

Gem::Specification.new do |spec|
  spec.name          = "govuk_tech_docs"
  spec.version       = GovukTechDocs::VERSION
  spec.authors       = ["Government Digital Service"]
  spec.email         = ["govuk-dev@digital.cabinet-office.gov.uk"]

  spec.summary       = "Gem to distribute the GOV.UK Tech Docs Template"
  spec.description   = "Gem to distribute the GOV.UK Tech Docs Template. See https://github.com/alphagov/tech-docs-gem for the project."
  spec.homepage      = "https://github.com/alphagov/tech-docs-gem"
  spec.license       = "MIT"

  files_in_git = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }

  # Include assets from GOV.UK Frontend library in the distributed gem
  govuk_frontend_assets = Dir["node_modules/govuk-frontend/**/*.{scss,js,mjs,woff,woff2,png,svg,ico}", "node_modules/govuk-frontend/dist/govuk/assets/**/*.json"]

  spec.files         = files_in_git + govuk_frontend_assets

  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = %w[lib]

  spec.required_ruby_version = ">= 3.3.0"

  spec.add_dependency "autoprefixer-rails"
  spec.add_dependency "chronic"
  spec.add_dependency "concurrent-ruby"
  spec.add_dependency "csv" # TODO: remove once tilt declares this itself.
  spec.add_dependency "haml", "~> 6.0" # middleman-core (4.6.3) depends on haml (>= 4.0.5, < 7)
  spec.add_dependency "middleman"
  spec.add_dependency "middleman-autoprefixer"
  spec.add_dependency "middleman-compass"
  spec.add_dependency "middleman-livereload"
  spec.add_dependency "middleman-search-gds"
=begin
middleman-sprockets is very old and out of date.  V4.1.0 has a breaking change.  Will look to replace with gem "dartsass-sprockets" or uses sass in the package.json
=end
  spec.add_dependency "middleman-sprockets", "4.0.0"
  spec.add_dependency "middleman-syntax"
  spec.add_dependency "mutex_m" # TODO: remove once activesupport declares this itself.
  spec.add_dependency "nokogiri"
  spec.add_dependency "openapi3_parser"
  spec.add_dependency "redcarpet"
  spec.add_dependency "sassc-embedded"
  spec.add_dependency "schmooze", "~> 0.2.0"
  spec.add_dependency "terser", "~> 1.2.3"

  spec.add_development_dependency "benchmark"
  spec.add_development_dependency "byebug"
  spec.add_development_dependency "capybara"
  spec.add_development_dependency "ostruct"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rubocop-govuk"
end
