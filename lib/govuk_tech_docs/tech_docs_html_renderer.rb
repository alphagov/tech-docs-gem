require "middleman-core/renderers/kramdown"

module Middleman
  module Renderers
    class MiddlemanKramdownHTML
      def convert_header(element, indent)
        attr = element.attr.dup
        if @options[:auto_ids] && !attr["id"]
          attr["id"] = UniqueIdentifierGenerator.instance.create(element.options[:raw_text], element.options[:level])
        end
        @toc << [element.options[:level], attr["id"], element.children] if attr["id"] && in_toc?(element)
        level = output_header_level(element.options[:level])
        format_as_block_html("h#{level}", attr, inner(element, indent), indent)
      end

      def convert_img(element, _indent)
        %(<a href="#{element.attr['src']}" rel="noopener noreferrer">#{super}</a>)
      end

      def convert_table(_element, _indent)
        %(<div class="table-container">
        #{super}
      </div>)
      end

      def convert_p(element, indent)
        app.api("<p>#{inner(element, indent).strip}</p>\n")
      end

      def app
        context.respond_to?(:app) ? context.app : context
      end

      def context
        @context ||= @options[:context]
      end
    end
  end
end
