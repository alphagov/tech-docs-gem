require 'erb'
require 'openapi3_parser'
require 'uri'
require 'pry'

module GovukTechDocs
  class ApiReference < Middleman::Extension
    expose_to_application api: :api

    def initialize(app, options_hash = {}, &block)
      super

      @app = app
      @config = @app.config[:tech_docs]

      # If no api path then just return.
      if @config['api_path'].to_s.empty?
        # @TODO Throw a middleman error?
        return
      end

      # Is the api_path a url or path?
      if uri?@config['api_path']
        @api_parser = true
        @document = Openapi3Parser.load_url(@config['api_path'])
      elsif File.exist?(@config['api_path'])
        # Load api file and set existence flag.
        @api_parser = true
        @document = Openapi3Parser.load_file(@config['api_path'])
      else
        # @TODO Throw a middleman error?
        @api_parser = false
      end

      # Load template files
      @render_api_full = get_renderer('api_reference_full.html.erb')
      @render_path = get_renderer('path.html.erb')
      @render_schema = get_renderer('schema.html.erb')
    end

    def uri?(string)
      uri = URI.parse(string)
      %w(http https).include?(uri.scheme)
    rescue URI::BadURIError
      false
    rescue URI::InvalidURIError
      false
    end

    def api(text)
      if @api_parser == true

        map = {
          'api&gt;' => 'default',
          'api_schema&gt;' => 'schema'
        }

        regexp = map.map { |k, _| Regexp.escape(k) }.join('|')

        md = text.match(/^<p>(#{regexp})/)
        if md
          key = md.captures[0]
          type = map[key]

          text.gsub!(/#{ Regexp.escape(key) }\s+?/, '')

          # Strip paragraph tags from text
          text = text.gsub(/<\/?[^>]*>/, '')
          text = text.strip

          if type == 'default'
            api_path_render(text)
          else
            api_schema_render(text)
          end

        else
          return text
        end
      else
        text
      end
    end

    def api_path_render(text)
      if text == 'api&gt;'
        return api_full
      else
        # Call api parser on text
        path = @document.paths[text]
        output = @render_path.result(binding)
        return output
      end
    end

    def api_schema_render(text)
      schemas = ''
      schemas_data = @document.components.schemas
      schemas_data.each do |schema_data|
        if schema_data[0] == text
          title = schema_data[0]
          schema = schema_data[1]
          output = @render_schema.result(binding)
          return output
        end
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
      schemas = api_schema_render('')
      @render_api_full.result(binding)
    end

    def render_markdown(text)
      if text
        Tilt['markdown'].new(context: @app) { text }.render
      end
    end

  private

    def get_renderer(file)
      template_path = File.join(File.dirname(__FILE__), 'templates/' + file)
      template = File.open(template_path, 'r').read
      ERB.new(template)
    end

    def get_operations(path)
      operations = {}
      operations['get'] = path.get if defined? path.get
      operations['put'] = path.put if defined? path.put
      operations['post'] = path.post if defined? path.post
      operations['delete'] = path.delete if defined? path.delete
      operations['patch'] = path.patch if defined? path.patch
      operations
    end

    def api_info
      @document.info
    end

    def api_server
      @document.servers[0]
    end

    def get_schema_name(text)
      unless text.is_a?(String)
        return nil
      end
      # Schema dictates that it's always components['schemas']
      text.gsub(/#\/components\/schemas\//, '')
    end
  end
end

::Middleman::Extensions.register(:api_reference, GovukTechDocs::ApiReference)
