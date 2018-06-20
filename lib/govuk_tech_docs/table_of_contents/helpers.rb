require 'govuk_tech_docs/table_of_contents/heading_tree_builder'
require 'govuk_tech_docs/table_of_contents/heading_tree_renderer'
require 'govuk_tech_docs/table_of_contents/heading_tree'
require 'govuk_tech_docs/table_of_contents/heading'
require 'govuk_tech_docs/table_of_contents/headings_builder'

module GovukTechDocs
  module TableOfContents
    module Helpers
      def single_page_table_of_contents(html, url: '', max_level: nil)
        headings = HeadingsBuilder.new(html, url).headings

        if headings.none? { |heading| heading.size == 1 }
          raise "No H1 tag found. You have to at least add one H1 heading to the page: " + url
        end

        tree = HeadingTreeBuilder.new(headings).tree
        HeadingTreeRenderer.new(tree, max_level: max_level).html
      end

      def multi_page_table_of_contents(resources, current_page, config, current_page_html = nil)
        # Only parse top level html files
        # Sorted by weight frontmatter
        resources = resources
        .select { |r| r.path.end_with?(".html") && (r.parent.nil? || r.parent.path.include?("index.html")) }
        .sort_by { |r| [r.data.weight ? 0 : 1, r.data.weight || 0] }

        output = '';
        resources.each do |resource|
          # Reuse the generated content for the active page
          # If we generate it twice it increments the heading ids
          content =
            if current_page.url == resource.url && current_page_html
              current_page_html
            else
              resource.render(layout: false)
            end

          # Avoid redirect pages
          next if content.include? "http-equiv=refresh"
          output <<
            single_page_table_of_contents(
              content,
              url: resource.url,
              max_level: config[:tech_docs][:max_toc_heading_level]
            )
        end
        output
      end
    end
  end
end
