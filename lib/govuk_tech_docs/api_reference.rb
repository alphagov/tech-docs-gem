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

      # Load template files
      @render_api_full = get_renderer('api_reference_full.html.erb')
      @render_path = get_renderer('path.html.erb')
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

            output = @render_path.result(binding)
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
      server = api_server

      paths = ''
      paths_data = @document.paths
      paths_data.each do |path_data|
        # For some reason paths.each returns an array of arrays [title, object]
        # instead of an array of objects
        text = path_data[0]
        path = path_data[1]
        paths += @render_path.result(binding)
      end
      output = @render_api_full.result(binding)
      return output
    end

    def api_info
      return @document.info
    end

    def api_server
      return @document.servers[0]
    end

    def api_components(text)
      # Schema dictates that it's always components['schemas']
      text = text = text.gsub(/#\/components\/schemas\//, "")

      components = @document.components['schemas'][text].node_data

      return components
    end

    def get_renderer(file)
      template_path = File.join( File.dirname(__FILE__), file)
      template = File.open(template_path, 'r').read
      return ERB.new(template)
    end
  end
end
