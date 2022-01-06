require "govuk_tech_docs/table_of_contents/heading_tree_builder"
require "govuk_tech_docs/table_of_contents/heading_tree_renderer"
require "govuk_tech_docs/table_of_contents/heading_tree"
require "govuk_tech_docs/table_of_contents/heading"
require "govuk_tech_docs/table_of_contents/headings_builder"

module GovukTechDocs
  module TableOfContents
    module Helpers
      def single_page_table_of_contents(html, url: "", max_level: nil)
        output = "<ul>\n"
        output += list_items_from_headings(html, url: url, max_level: max_level)
        output += "</ul>\n"

        output
      end

      def multi_page_table_of_contents(resources, current_page, config, current_page_html = nil)
        # Only parse top level html files
        # Sorted by weight frontmatter
        resources = resources
        .select { |r| r.path.end_with?(".html") && (r.parent.nil? || r.parent.url == "/") }
        .sort_by { |r| [r.data.weight ? 0 : 1, r.data.weight || 0] }

        render_page_tree(resources, current_page, config, current_page_html)
      end

      def list_items_from_headings(html, url: "", max_level: nil)
        headings = HeadingsBuilder.new(html, url).headings

        if headings.none? { |heading| heading.size == 1 }
          raise "No H1 tag found. You have to at least add one H1 heading to the page: " + url
        end

        tree = HeadingTreeBuilder.new(headings).tree
        HeadingTreeRenderer.new(tree, max_level: max_level).html
      end

      def get_resource_link_value(config, resource, current_page)
        if config[:relative_links]
          current_page_segments = current_page.path.split("/").reject(&:empty?)[0..-2]
          resource_path_segments = resource.path.split("/").reject(&:empty?)[0..-2]
          resource_file_name = resource.path.split("/")[-1]
          number_of_ascents_to_site_root = current_page_segments.length

          if number_of_ascents_to_site_root == 0
            ascents = ["."]
          else
            ascents = number_of_ascents_to_site_root.times.collect { ".." }
          end

          link_value = ascents.concat(resource_path_segments)
                              .push(resource_file_name)
                              .join("/")

        else
          link_value = resource.url
        end
        link_value
      end

      def path_to_site_root(*args, &block)
        if config[:relative_links]
          current_page_url = args[0]
          number_of_ascents_to_site_root = current_page_url.to_s.split("/").length() - 1
          if number_of_ascents_to_site_root == 0
            ascents = ["."]
          else
            ascents = number_of_ascents_to_site_root.times.collect { ".." }
          end
          path_to_site_root = ascents.join("/").concat('/')
        else
          path_to_site_root = "/"
        end
        path_to_site_root
      end

      def render_page_tree(resources, current_page, config, current_page_html)
        # Sort by weight frontmatter
        resources = resources
        .sort_by { |r| [r.data.weight ? 0 : 1, r.data.weight || 0] }

        output = "<ul>\n"
        resources.each do |resource|
          # Skip from page tree if hide_in_navigation:true frontmatter
          next if resource.data.hide_in_navigation

          # Reuse the generated content for the active page
          # If we generate it twice it increments the heading ids
          content = if current_page.url == resource.url && current_page_html
                      current_page_html
                    else
                      resource.render(layout: false)
                    end
          # Avoid redirect pages
          next if content.include? "http-equiv=refresh"

          # If this page has children, just print the title and recursively
          # render the children. If not, print the heading structure.

          # We avoid printing the children of the root index.html as it is the
          # parent of every other top level file.  We need to take any custom
          # prefix in to consideration when checking for the root index.html.
          # The prefix may be set with or without a trailing slash: make sure
          # it has one for this comparison check.
          home_url =
            if config[:http_prefix].end_with?("/")
              config[:http_prefix]
            else
              config[:http_prefix] + "/"
            end

          link_value = get_resource_link_value(config, resource, current_page)
          if resource.children.any? && resource.url != home_url
            output += %{<li><a href="#{link_value}"><span>#{resource.data.title}</span></a>\n}
            output += render_page_tree(resource.children, current_page, config, current_page_html)
            output += "</li>\n"
          else
            output +=
              list_items_from_headings(
                content,
                url: link_value,
                max_level: config[:tech_docs][:max_toc_heading_level],
              )
          end
        end
        output += "</ul>\n"

        output
      end
    end
  end
end
