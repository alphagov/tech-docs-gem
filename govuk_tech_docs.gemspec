require "English"

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "govuk_tech_docs/version"

npm_available = system(
  "npm",
  "--version",
  out: File::NULL,
  err: File::NULL
)

npm_runtime_files = []

if npm_available
  include_dev_dependencies =
    ENV["INCLUDE_NPM_DEV_DEPENDENCIES"] == "true"

  npm_install_args = %w[npm ci]
  npm_install_args << "--omit=dev" unless include_dev_dependencies

  system(*npm_install_args) ||
    abort("#{npm_install_args.join(' ')} failed")

  required_npm_files = %w[
    node_modules/govuk-frontend/package.json
    node_modules/govuk-frontend/dist/govuk/_base.scss
    node_modules/govuk-frontend/dist/govuk/components/button/macro.njk
    node_modules/nunjucks/package.json
  ]

  missing_npm_files = required_npm_files.reject do |file|
    File.file?(file)
  end

  unless missing_npm_files.empty?
    abort(
      "Required npm files were not installed:\n" \
        "#{missing_npm_files.join("\n")}"
    )
  end

  npm_runtime_files = Dir.glob(
    "node_modules/**/*",
    File::FNM_DOTMATCH
  ).select do |path|
    File.file?(path) || File.symlink?(path)
  end
else
  warn(
    "npm is not available, so npm runtime packages will not be included. " \
      "This is expected when evaluating the gemspec, but npm must be " \
      "available when building the distributable gem."
  )
end

Gem::Specification.new do |spec|
  spec.name          = "govuk_tech_docs"
  spec.version       = GovukTechDocs::VERSION
  spec.authors       = ["Government Digital Service"]
  spec.email         = ["govuk-dev@digital.cabinet-office.gov.uk"]

  spec.summary = "Gem to distribute the GOV.UK Tech Docs Template"
  spec.description = <<~DESCRIPTION.strip
    Gem to distribute the GOV.UK Tech Docs Template.
    See https://github.com/alphagov/tech-docs-gem for the project.
  DESCRIPTION

  spec.homepage = "https://github.com/alphagov/tech-docs-gem"
  spec.license  = "MIT"

  files_in_git = `git ls-files -z`
                   .split("\x0")
                   .reject do |file|
    file.match?(%r{\A(?:test|spec|features|\.github|documentation)/})
  end

  spec.files = (files_in_git + npm_runtime_files).uniq.sort

  spec.bindir = "exe"
  spec.executables = spec.files
                         .grep(%r{\Aexe/})
                         .map { |file| File.basename(file) }

  spec.require_paths = %w[lib]

  spec.required_ruby_version = ">= 3.3.0"

  spec.add_dependency "autoprefixer-rails"
  spec.add_dependency "chronic"
  spec.add_dependency "concurrent-ruby"

  # TODO: remove once tilt declares this itself.
  spec.add_dependency "csv"

  # middleman-core 4.6.3 depends on haml >= 4.0.5 and < 7.
  spec.add_dependency "haml", ">= 6", "< 8"

  spec.add_dependency "middleman"
  spec.add_dependency "middleman-autoprefixer"
  spec.add_dependency "middleman-compass"
  spec.add_dependency "middleman-livereload"
  spec.add_dependency "middleman-search-gds"

  # middleman-sprockets is very old and out of date.
  # Version 4.1.0 contains a breaking change.
  spec.add_dependency "middleman-sprockets", "4.0.0"

  spec.add_dependency "middleman-syntax"

  # TODO: remove once Active Support declares this itself.
  spec.add_dependency "mutex_m"

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