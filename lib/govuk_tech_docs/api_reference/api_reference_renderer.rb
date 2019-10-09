require 'erb'
require 'json'

module GovukTechDocs
  module ApiReference
    class Renderer
      RENDERABLE_OPERATIONS = %w[get put post delete patch].freeze

      def initialize(app, document)
        @app = app
        @document = document

        # Load template files
        @template_api_full = get_renderer('api_reference_full.html.erb')
        @template_path = get_renderer('path.html.erb')
        @template_schema = get_renderer('schema.html.erb')
        @template_operation = get_renderer('operation.html.erb')
        @template_parameters = get_renderer('parameters.html.erb')
        @template_responses = get_renderer('responses.html.erb')
      end

      def render_api_full(info, servers)
        paths = @document.paths.keys.inject('') do |memo, path|
          memo + render_path(path)
        end

        schemas = ''
        schemas_data = @document.components.schemas
        schemas_data.each do |schema_data|
          text = schema_data[0]
          schemas += schema(text)
        end
        @template_api_full.result(binding)
      end

      def render_path(path)
        path_item = @document.paths[path]
        raise "path_item not found for #{path}" unless path_item

        id = path.parameterize
        operations = render_operations(path, path_item)
        @template_path.result(binding)
      end

      def schema(text)
        schemas = ''
        schemas_data = @document.components.schemas
        schemas_data.each do |schema_data|
          all_of = schema_data[1]["allOf"]
          properties = []
          if !all_of.blank?
            all_of.each do |schema_nested|
              schema_nested.properties.each do |property|
                properties.push property
              end
            end
          end

          schema_data[1].properties.each do |property|
            properties.push property
          end

          if schema_data[0] == text
            title = schema_data[0]
            schema = schema_data[1]
            return @template_schema.result(binding)
          end
        end
      end

      def schemas_from_path(text)
        path = @document.paths[text]
        operations = get_operations(path)
        # Get all referenced schemas
        schemas = []
        operations.compact.each_value do |operation|
          responses = operation.responses
          responses.each do |_rkey, response|
            if response.content['application/json']
              schema = response.content['application/json'].schema
              schema_name = get_schema_name(schema.node_context.source_location.to_s)
              if !schema_name.nil?
                schemas.push schema_name
              end
              schemas.concat(schemas_from_schema(schema))
            end
          end
        end
        # Render all referenced schemas
        output = ''
        schemas.uniq.each do |schema_name|
          output += schema(schema_name)
        end
        if !output.empty?
          output.prepend('<h2 id="schemas">Schemas</h2>')
        end
        output
      end

      def schemas_from_schema(schema)
        schemas = []
        properties = []
        schema.properties.each do |property|
          properties.push property[1]
        end
        if schema.type == 'array'
          properties.push schema.items
        end
        all_of = schema["allOf"]
        if !all_of.blank?
          all_of.each do |schema_nested|
            schema_nested.properties.each do |property|
              properties.push property[1]
            end
          end
        end
        properties.each do |property|
          if property.name
            schemas.push property.name
          end

          # Check sub-properties for references
          schemas.concat(schemas_from_schema(property))
        end
        schemas
      end

      def render_operations(path, path_item)
        path_item.inject('') do |memo, (field, operation)|
          next memo if operation.nil? || !RENDERABLE_OPERATIONS.include?(field)

          id = "#{path.parameterize}-#{field.parameterize}"
          parameters = render_parameters(id, operation)
          responses = render_responses(id, operation)
          memo + @template_operation.result(binding)
        end
      end

      def render_parameters(operation_id, operation)
        parameters = operation.parameters
        id = "#{operation_id}-parameters"
        @template_parameters.result(binding)
      end

      def render_responses(operation_id, operation)
        responses = operation.responses
        id = "#{operation_id}-responses"
        @template_responses.result(binding)
      end

      def markdown(text)
        if text
          Tilt['markdown'].new(context: @app) { text }.render
        end
      end

      def render_json_schema(schema)
        properties = schema_properties(schema)
        JSON.pretty_generate(properties)
      end

      def schema_properties(schema_data)
        properties = Hash.new
        if defined? schema_data.properties
          schema_data.properties.each do |key, property|
            properties[key] = property
          end
        end
        properties.merge! get_all_of_hash(schema_data)
        properties_hash = Hash.new
        properties.each do |pkey, property|
          if property.type == 'object'
            properties_hash[pkey] = Hash.new
            items = property.items
            if !items.blank?
              properties_hash[pkey] = schema_properties(items)
            end
            if !property.properties.blank?
              properties_hash[pkey] = schema_properties(property)
            end
          elsif property.type == 'array'
            properties_hash[pkey] = Array.new
            items = property.items
            if !items.blank?
              properties_hash[pkey].push schema_properties(items)
            end
          else
            properties_hash[pkey] = !property.example.nil? ? property.example : property.type
          end
        end

        properties_hash
      end

    private

      def get_all_of_array(schema)
        properties = Array.new
        if schema.is_a?(Array)
          schema = schema[1]
        end
        if schema["allOf"]
          all_of = schema["allOf"]
        end
        if !all_of.blank?
          all_of.each do |schema_nested|
            schema_nested.properties.each do |property|
              if property.is_a?(Array)
                property = property[1]
              end
              properties.push property
            end
          end
        end
        properties
      end

      def get_all_of_hash(schema)
        properties = Hash.new
        if schema["allOf"]
          all_of = schema["allOf"]
        end
        if !all_of.blank?
          all_of.each do |schema_nested|
            schema_nested.properties.each do |key, property|
              properties[key] = property
            end
          end
        end
        properties
      end

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

      def schema_link(schema)
        return unless schema.name

        id = "schema-#{schema_name.parameterize}"
        "<a href='\##{id}'>#{schema.name}</a>"
      end

      def get_schema_link(schema)
        schema_name = get_schema_name schema.node_context.source_location.to_s
        if !schema_name.nil?
          id = "schema-#{schema_name.parameterize}"
          output = "<a href='\##{id}'>#{schema_name}</a>"
          output
        end
      end
    end
  end
end
