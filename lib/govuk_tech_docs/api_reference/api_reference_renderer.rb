require "erb"
require "json"

module GovukTechDocs
  module ApiReference
    class Renderer
      def initialize(app, document)
        @app = app
        @document = document
        @redcarpet = build_redcarpet(app)

        # Load template files
        @template_api_full = get_renderer("api_reference_full.html.erb")
        @template_path = get_renderer("path.html.erb")
        @template_schema = get_renderer("schema.html.erb")
        @template_operation = get_renderer("operation.html.erb")
        @template_parameters = get_renderer("parameters.html.erb")
        @template_responses = get_renderer("responses.html.erb")
      end

      def api_full(info, servers)
        paths = @document.paths.keys.inject("") do |memo, text|
          memo + path(text)
        end

        schema_names = @document.components.schemas.keys
        schemas = schema_names.inject("") do |memo, schema_name|
          memo + schema(schema_name)
        end

        @template_api_full.result(binding)
      end

      def path(text)
        path = @document.paths[text]
        id = text.parameterize
        operations = operations(path, id)
        @template_path.result(binding)
      end

      def schema(title)
        schema = @document.components.schemas[title]
        return unless schema

        properties = if schema.all_of
                       schema.all_of.each_with_object({}) do |nested, memo|
                         memo.merge!(nested.properties.to_h)
                       end
                     else
                       {}
                     end

        properties.merge!(schema.properties.to_h)
        @template_schema.result(binding)
      end

      def schemas_from_path(text)
        operations = get_operations(@document.paths[text])
        schemas = operations.flat_map do |_, operation|
          operation.responses.inject([]) do |memo, (_, response)|
            next memo unless response.content["application/json"]

            schema = response.content["application/json"].schema

            memo << schema.name if schema.name
            memo + schemas_from_schema(schema)
          end
        end

        # Render all referenced schemas
        output = schemas.uniq.inject("") do |memo, schema_name|
          memo + schema(schema_name)
        end

        output.prepend('<h2 id="schemas">Schemas</h2>') unless output.empty?
        output
      end

      def schemas_from_schema(schema)
        schemas = schema.properties.map(&:last)
        schemas << schema.items if schema.items && schema.type == "array"
        schemas += schema.all_of.to_a.flat_map { |s| s.properties.map(&:last) }

        schemas.flat_map do |nested|
          sub_schemas = schemas_from_schema(nested)
          nested.name ? [nested.name] + sub_schemas : sub_schemas
        end
      end

      def operations(path, path_id)
        get_operations(path).inject("") do |memo, (key, operation)|
          id = "#{path_id}-#{key.parameterize}"
          parameters = parameters(operation, id)
          responses = responses(operation, id)
          memo + @template_operation.result(binding)
        end
      end

      def parameters(operation, operation_id)
        parameters = operation.parameters
        id = "#{operation_id}-parameters"
        @template_parameters.result(binding)
      end

      def responses(operation, operation_id)
        responses = operation.responses
        id = "#{operation_id}-responses"
        @template_responses.result(binding)
      end

      def json_output(schema)
        properties = schema_properties(schema)
        JSON.pretty_generate(properties)
      end

      def json_prettyprint(data)
        JSON.pretty_generate(data)
      end

      def schema_properties(schema_data)
        properties = schema_data.properties.to_h

        schema_data.all_of.to_a.each do |all_of_schema|
          properties.merge!(all_of_schema.properties.to_h)
        end

        properties.transform_values do |schema|
          case schema.type
          when "object"
            schema_properties(schema.items || schema)
          when "array"
            schema.items ? [schema_properties(schema.items)] : []
          else
            schema.example || schema.type
          end
        end
      end

    private

      def build_redcarpet(app)
        renderer = GovukTechDocs::TechDocsHTMLRenderer.new(context: app.config_context)
        Redcarpet::Markdown.new(renderer)
      end

      def get_renderer(file)
        template_path = File.join(File.dirname(__FILE__), "templates/#{file}")
        template = File.open(template_path, "r").read
        ERB.new(template)
      end

      def get_operations(path)
        {
          "get" => path.get,
          "put" => path.put,
          "post" => path.post,
          "delete" => path.delete,
          "patch" => path.patch,
        }.compact
      end

      def get_schema_link(schema)
        return unless schema.name

        id = "schema-#{schema.name.parameterize}"
        "<a href='\##{id}'>#{schema.name}</a>"
      end

      def render_markdown(text)
        @redcarpet.render(text) if text
      end
    end
  end
end
