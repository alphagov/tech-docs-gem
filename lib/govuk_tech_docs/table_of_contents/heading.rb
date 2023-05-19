module GovukTechDocs
  module TableOfContents
    class Heading
      def initialize(element_name:, text:, attributes:, page_url: "")
        @element_name = element_name
        @text = text
        @attributes = attributes
        @page_url = page_url
      end

      def size
        @element_name.scan(/h(\d)/) && ::Regexp.last_match(1) && Integer(::Regexp.last_match(1))
      end

      def href
        if @page_url != "" && size == 1
          @page_url
        else
          "#{@page_url}##{@attributes['id']}"
        end
      end

      def title
        @text
      end

      def ==(other)
        @element_name == other.instance_variable_get("@element_name") &&
          @text == other.instance_variable_get("@text") &&
          @attributes == other.instance_variable_get("@attributes")
      end
    end
  end
end
