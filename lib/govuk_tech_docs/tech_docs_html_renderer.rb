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
      %(<h#{level} id="#{anchor}">#{text}</h#{level}>)
    end

    def image(link, *args)
      %(<a href="#{link}" rel="noopener noreferrer">#{super}</a>)
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
      #
      # Despite the hackiness, this substitution should work for all cases
      # where the table cell just includes simple text (with no other markup).

      body_with_row_headers = body.gsub(/<td># ([^<]*)<\/td>/, "<th scope=\"row\">\\1</th>")
      "<tr>#{body_with_row_headers}</tr>"
    end
  end
end
