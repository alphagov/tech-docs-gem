require 'govuk_tech_docs/table_of_contents/heading_tree_builder'
require 'govuk_tech_docs/table_of_contents/heading_tree_renderer'
require 'govuk_tech_docs/table_of_contents/heading_tree'
require 'govuk_tech_docs/table_of_contents/heading'
require 'govuk_tech_docs/table_of_contents/headings_builder'

module GovukTechDocs
  module TableOfContents
    module Helpers
      def table_of_contents(html, max_level: nil)
        headings = HeadingsBuilder.new(html).headings

        if headings.none? { |heading| heading.size == 1 }
          raise "No H1 tag found. You have to at least add one H1 heading to the page."
        end

        tree = HeadingTreeBuilder.new(headings).tree
        HeadingTreeRenderer.new(tree, max_level: max_level).html
      end
    end
  end
end
