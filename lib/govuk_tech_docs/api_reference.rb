module GovukTechDocs
  # Helper included
  module ApiReferenceHelper
    def api_reference
      ApiReference.new(config)
    end
  end

  class ApiReference
    attr_reader :config

    def initialize(config)
      # @text = text
      @config = config

      print config
    end

    def api(text)
      # @TODO Need to grab the config object.
      #
      # @TODO if no text then output everything

      # @TODO I think this is overkill at the moment.
      map = {
          "api&gt;" => ""
      }

      regexp = map.map { |k, _| Regexp.escape(k) }.join("|")

      if md = text.match(/^<p>(#{regexp})/)
        key = md.captures[0]
        text.gsub!(/#{Regexp.escape(key)}\s+?/, "")

        # @TODO This should be a template file.
        return <<-EOH.gsub(/^ {8}/, "")
        <div class="api-builder">
        <pre>#{text} </pre>
        </div>
        EOH
      else
        return text
      end
    end
  end
end