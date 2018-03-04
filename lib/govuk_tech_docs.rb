require 'govuk_tech_docs/version'

require 'middleman'
require 'middleman-autoprefixer'
require 'middleman-sprockets'
require 'middleman-livereload'
require 'middleman-syntax'

require 'nokogiri'

require 'govuk_tech_docs/table_of_contents/helpers'
require 'govuk_tech_docs/tech_docs_html_renderer'
require 'govuk_tech_docs/unique_identifier_extension'
require 'govuk_tech_docs/unique_identifier_generator'

module GovukTechDocs
  def self.configure(context)
    context.activate :autoprefixer
    context.activate :sprockets
    context.activate :syntax

    context.files.watch :source, path: "#{__dir__}/source"

    context.set :markdown_engine, :redcarpet
    context.set :markdown,
        renderer: TechDocsHTMLRenderer.new(
          with_toc_data: true
        ),
        fenced_code_blocks: true,
        tables: true,
        no_intra_emphasis: true

    # Reload the browser automatically whenever files change
    context.configure :development do
      activate :livereload
    end

    context.configure :build do
      activate :minify_css
      activate :minify_javascript
    end

    context.config[:tech_docs] = YAML.load_file('config/tech-docs.yml').with_indifferent_access
    context.activate :unique_identifier

    context.helpers do
      include GovukTechDocs::TableOfContents::Helpers
    end

    context.page '/*.xml', layout: false
    context.page '/*.json', layout: false
    context.page '/*.txt', layout: false
  end
end
