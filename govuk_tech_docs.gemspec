require "English"

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "govuk_tech_docs/version"

`npm install`
abort "npm install failed" unless $CHILD_STATUS.success?

unless File.exist?("node_modules/govuk-frontend/dist/govuk/all.scss")
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
  govuk_frontend_assets = Dir["node_modules/govuk-frontend/**/*.{scss,js,mjs,woff,woff2,png,svg,ico}", "node_modules/govuk-frontend/dist/govuk/assets/manifest.json"]

  spec.files         = files_in_git + govuk_frontend_assets

  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = %w[lib]

  spec.required_ruby_version = ">= 3.1.0"

  spec.add_dependency "autoprefixer-rails", "~> 10.2"
  spec.add_dependency "base64" # TODO: remove once middleman-sprockets declares this itself.
  spec.add_dependency "bigdecimal" # TODO: remove once activesupport declares this itself.
  spec.add_dependency "chronic", "~> 0.10.2"
  spec.add_dependency "concurrent-ruby", "1.3.4" # 1.3.5 introduced a change that breaks activesupport, and so middleman
  spec.add_dependency "csv" # TODO: remove once tilt declares this itself.
  spec.add_dependency "haml", "~> 6.0"
  spec.add_dependency "middleman", "4.5.1" # remove pin once https://github.com/middleman/middleman/issues/2818 is fixed
  spec.add_dependency "middleman-autoprefixer", "~> 2.10"
  spec.add_dependency "middleman-compass", "~> 4.0"
  spec.add_dependency "middleman-livereload"
  spec.add_dependency "middleman-search-gds"
  spec.add_dependency "middleman-sprockets", "~> 4.0.0"
  spec.add_dependency "middleman-syntax", "~> 3.4"
  spec.add_dependency "mutex_m" # TODO: remove once activesupport declares this itself.
  spec.add_dependency "nokogiri"
  spec.add_dependency "openapi3_parser", "~> 0.9.0"
  spec.add_dependency "redcarpet", "~> 3.6"
  spec.add_dependency "terser", "~> 1.2.3"
  spec.add_dependency "sassc-embedded", "~> 1.78.0"

  spec.add_development_dependency "byebug"
  spec.add_development_dependency "capybara", "~> 3.32"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.9"
  spec.add_development_dependency "rubocop-govuk", "~> 4.10"
end
