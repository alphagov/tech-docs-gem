module GovukTechDocs
  class ApiReference
    def api(text)
      # Need to grab the config object.
      config = YAML.load_file('config/tech-docs.yml')

      # If no api path then just return the text.
      if config["api_path"].to_s.empty?
        return text
      end

      # @TODO I think this is overkill at the moment.
      map = {
          "api&gt;" => ""
      }

      # @TODO if there is just api> then print everything

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