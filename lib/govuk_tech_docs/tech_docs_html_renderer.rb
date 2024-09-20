require "middleman-core/renderers/redcarpet"

module GovukTechDocs
  class TechDocsHTMLRenderer < Middleman::Renderers::MiddlemanRedcarpetHTML
    include Redcarpet::Render::SmartyPants

    def initialize(options = {})
      @local_options = options.dup
      @app = @local_options[:context].app
      super
    end

    def paragraph(text)
      @app.api("<p>#{text.strip}</p>\n")
    end

    def header(text, level)
      anchor = UniqueIdentifierGenerator.instance.create(text, level)
      %(<h#{level} id="#{anchor}">#{text}</h#{level}>\n)
    end

    def image(link, title, alt_text)
      if alt_text && !alt_text.strip.empty?
        %(<a href="#{link}" rel="noopener noreferrer">#{super}</a>)
      else
        super
      end
    end

    def table(header, body)
      %(<div class="table-container">
        <table>
          #{header}#{body}
        </table>
      </div>)
    end

    def table_row(body)
      # Post-processing the table_cell HTML to implement row headings.
      #
      # Doing this in table_row instead of table_cell is a hack.
      #
      # Ideally, we'd use the table_cell callback like:
      #
      # def table_cell(content, alignment, header)
      #   if header
      #     "<th>#{content}</th>"
      #   elsif content.start_with? "# "
      #     "<th scope="row">#{content.sub(/^# /, "")}</th>"
      #   else
      #     "<td>#{content}</td>"
      #   end
      # end
      #
      # Sadly, Redcarpet's table_cell callback doesn't allow you to distinguish
      # table cells and table headings until https://github.com/vmg/redcarpet/commit/27dfb2a738a23aadd286ac9e7ecd61c4545d29de
      # (which is not yet released). This means we can't use the table_cell callback
      # without breaking column headers, so we're having to hack it in table_row.

      fragment = Nokogiri::HTML::DocumentFragment.parse(body)
      fragment.children.each do |cell|
        next unless cell.name == "td"
        next if cell.children.empty?

        first_child = cell.children.first
        next unless first_child.text?

        leading_text = first_child.content
        next unless leading_text.start_with?("#")

        cell.name = "th"
        cell["scope"] = "row"
        first_child.content = leading_text.sub(/# */, "")
      end

      tr = Nokogiri::XML::Node.new "tr", fragment.document
      tr.children = fragment.children

      tr.to_html
    end

    def block_code(text, lang)
      if defined?(super)
        # Post-processing the block_code HTML to implement tabbable code blocks.
        #
        # Middleman monkey patches the Middleman::Renderers::MiddlemanRedcarpetHTML
        # to include Middleman::Syntax::RedcarpetCodeRenderer. This defines its own
        # version of `block_code(text, lang)` which we can call with `super`.

        fragment = Nokogiri::HTML::DocumentFragment.parse(super)
        fragment.traverse do |element|
          if element.name == "pre" && element["tabindex"].nil?
            element["tabindex"] = "0"
          end
        end
        fragment.to_html
      else
        # If syntax highlighting with redcarpet isn't enabled, super will not
        # be `defined?`, so we can jump straight to rendering HTML ourselves.

        fragment = Nokogiri::HTML::DocumentFragment.parse("")
        pre = Nokogiri::XML::Node.new "pre", fragment.document
        pre["tabindex"] = "0"
        code = Nokogiri::XML::Node.new "code", fragment.document
        code["class"] = lang
        code.content = text
        pre.add_child code
        pre.to_html
      end
    end
  end
end
