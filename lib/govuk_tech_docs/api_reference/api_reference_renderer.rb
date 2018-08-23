require 'erb'

module GovukTechDocs
  module ApiReference
    class Renderer
      def initialize(app, document)
        @app = app
        @document = document

        # Load template files
        @template_api_full = get_renderer('api_reference_full.html.erb')
        @template_path = get_renderer('path.html.erb')
        @template_schema = get_renderer('schema.html.erb')
      end

      def api_full(info, server)
        paths = ''
        paths_data = @document.paths
        paths_data.each do |path_data|
          # For some reason paths.each returns an array of arrays [title, object]
          # instead of an array of objects
          text = path_data[0]
          path = path_data[1]
          paths += @template_path.result(binding)
        end
        schemas = ''
        schemas_data = @document.components.schemas
        schemas_data.each do |schema_data|
          title = schema_data[0]
          schema = schema_data[1]
          schemas += @template_schema.result(binding)
        end
        @template_api_full.result(binding)
      end

      def path(text)
        path = @document.paths[text]
        operations = get_operations(path)
        output = @template_path.result(binding)
        output
      end

      def schema(text)
        schemas = ''
        schemas_data = @document.components.schemas
        schemas_data.each do |schema_data|
          if schema_data[0] == text
            title = schema_data[0]
            schema = schema_data[1]
            output = @template_schema.result(binding)
            return output
          end
        end
      end

      def markdown(text)
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

      def get_schema_name(text)
        unless text.is_a?(String)
          return nil
        end
        # Schema dictates that it's always components['schemas']
        text.gsub(/#\/components\/schemas\//, '')
      end
    end
  end
end

