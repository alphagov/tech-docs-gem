require "govuk_tech_docs/version"

require "middleman"
require "middleman-autoprefixer"
require "middleman-sprockets"
require "middleman-livereload"
require "middleman-syntax"
require "middleman-search"

require "nokogiri"
require "chronic"
require "active_support/all"
require "terser"
require "sassc-embedded"

require "govuk_tech_docs/redirects"
require "govuk_tech_docs/table_of_contents/helpers"
require "govuk_tech_docs/contribution_banner"
require "govuk_tech_docs/meta_tags"
require "govuk_tech_docs/page_review"
require "govuk_tech_docs/pages"
require "govuk_tech_docs/tech_docs_html_renderer"
require "govuk_tech_docs/unique_identifier_extension"
require "govuk_tech_docs/unique_identifier_generator"
require "govuk_tech_docs/warning_text_extension"
require "govuk_tech_docs/api_reference/api_reference_extension"

module SassWarningSupressor
  def warn(message)
    if message.to_s.match?(/Sass|dart-sass/i)
      # suppress dart sass warnings
    else
      super
    end
  end
end

Warning.extend(SassWarningSupressor)

module GovukTechDocs
  # Configure the tech docs template
  #
  # @param options [Hash]
  # @option options [Hash] livereload Options to pass to the `livereload`
  #   extension. Hash with symbols as keys.
  def self.configure(context, options = {})
    context.activate :sprockets

    context.sprockets.append_path File.join(__dir__, "../node_modules/govuk-frontend/dist")
    context.sprockets.append_path File.join(__dir__, "./source")

    context.activate :syntax

    context.files.watch :source, path: "#{__dir__}/source"

    context.set :markdown_engine, :redcarpet
    context.set :markdown,
                renderer: TechDocsHTMLRenderer.new(
                  with_toc_data: true,
                  api: true,
                  context:,
                ),
                fenced_code_blocks: true,
                tables: true,
                no_intra_emphasis: true

    # this doesnt seem to work
    context.set :sass, { output_style: "nested", quiet_deps: true }

    # Reload the browser automatically whenever files change
    context.configure :development do
      activate :livereload, options[:livereload].to_h
    end

    context.configure :build do
      activate :autoprefixer
      activate :minify_javascript, compressor: Terser.new, ignore: ["/raw_assets/*"]
    end

    config_file = ENV.fetch("CONFIG_FILE", "config/tech-docs.yml")
    context.config[:tech_docs] = YAML.load_file(config_file).with_indifferent_access
    context.activate :unique_identifier
    context.activate :warning_text
    context.activate :api_reference

    context.helpers do
      include GovukTechDocs::PathHelpers
      include GovukTechDocs::TableOfContents::Helpers
      include GovukTechDocs::ContributionBanner

      def meta_tags
        @meta_tags ||= GovukTechDocs::MetaTags.new(config, current_page)
      end

      def current_page_review
        @current_page_review ||= GovukTechDocs::PageReview.new(current_page, config)
      end

      def format_date(date)
        date.strftime("%-e %B %Y")
      end

      def active_page(page_path)
        [
          page_path == "/" && current_page.path == "index.html",
          "/#{current_page.path}" == page_path,
          !current_page.data.parent.nil? && current_page.data.parent.to_s == page_path,
        ].any?
      end
    end

    context.page "/*.xml", layout: false
    context.page "/*.json", layout: false
    context.page "/*.txt", layout: false

    context.ready do
      redirects = GovukTechDocs::Redirects.new(context).redirects

      redirects.each do |from, to|
        context.redirect from, to
      end
    end

    if context.config[:tech_docs][:enable_search]
      context.activate :search do |search|
        search.resources = [""]

        search.fields = {
          title: { boost: 100, store: true, required: true },
          content: { boost: 50, store: true },
          url: { index: false, store: true },
        }

        search.pipeline_remove = %w[stemmer stopWordFilter]

        search.tokenizer_separator = '/[\s\-/]+/'
      end
    else
      context.ignore "search/*"
    end
  end
end
