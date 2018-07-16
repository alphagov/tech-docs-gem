require 'erb'
require 'openapi3_parser'
require 'uri'

module GovukTechDocs
  class ApiReference
    def initialize
      # Need to grab the config object.
      @config = YAML.load_file('config/tech-docs.yml')

      # If no api path then just return.
      if @config["api_path"].to_s.empty?
        # @TODO Throw a middleman error?
        return
      end

      # Is the api_path a url or path?
      if uri?@config["api_path"]
        @api_parser = true

        @document = Openapi3Parser.load_url(@config["api_path"])
      else
        # Load api file and set existence flag.
        if File.exists?(@config["api_path"])
          @api_parser = true

          @document = Openapi3Parser.load_file(@config["api_path"])
        else
          # @TODO Throw a middleman error?
          @api_parser = false
        end
      end
    end

    def uri?(string)
      uri = URI.parse(string)
      %w( http https ).include?(uri.scheme)
    rescue URI::BadURIError
      false
    rescue URI::InvalidURIError
      false
    end

    def api(text)
      if @api_parser == true

        map = {
            "api&gt;" => ""
        }

        regexp = map.map {|k, _| Regexp.escape(k)}.join("|")

        if md = text.match(/^<p>(#{regexp})/)
          key = md.captures[0]
          text.gsub!(/#{Regexp.escape(key)}\s+?/, "")

          # Strip paragraph tags from text
          text = text.gsub(/<\/?[^>]*>/, "")
          text = text.strip

          if text == 'api&gt;'
            return api_full
          else
            # Call api parser on text
            path = @document.paths[text]

            template_path = File.join( File.dirname(__FILE__), 'path.html.erb')
            template = File.open(template_path, 'r').read
            renderer = ERB.new(template)
            output = renderer.result(binding)
            return output
          end

        else
          return text
        end

      else
        return text
      end
    end

    def api_full
      info = api_info

      paths = @document.paths.node_data

      template_path = File.join( File.dirname(__FILE__), 'api_reference_full.html.erb')
      template = File.open(template_path, 'r').read
      renderer = ERB.new(template)
      output = renderer.result(binding)
      return output
    end

    def api_info
      return @document.info.node_data
    end
  end
end
