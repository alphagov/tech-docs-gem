require 'middleman-core'

module YourDesignSystem
  class Extension < Middleman::Extension
    def initialize(app, options_hash={}, &block)
      super
    end

    helpers do 
      def get_component_template_name(component_name)
        component_name.to_s.delete_prefix("govuk")
                    .gsub(/([A-Z]+)([A-Z][a-z])/, '\1-\2') # Handle acronyms like "JSONData"
                    .gsub(/([a-z\d])([A-Z])/, '\1-\2')     # Handle standard "CamelCase"
                    .downcase
        # return template_name
      end
      
      def method_missing(method_name, *args, &block)
        case
          when method_name.to_s.start_with?('govuk')
            # 1. Setup the paths to your gem's Nunjucks files
            params = args.first || {}
            gem_root = File.expand_path('../../', __dir__)
            search_paths = [File.join(gem_root, 'node_modules/govuk-frontend/dist')]
            component_template_name = get_component_template_name(method_name)
            # 2. Build a Nunjucks string that imports the macro and calls it
            # This mimics the "direct call" behavior
            nunjucks_string = <<~NJK
              {% from "govuk/components/#{component_template_name}/macro.njk" import #{method_name} %}
              {{ #{method_name}(params) }}
            NJK

            # 3. Render via Schmooze
            begin
              @renderer ||= YourDesignSystem::NunjucksRenderer.new(gem_root)
              @renderer.render_string(nunjucks_string, { 'params' => params }, search_paths).html_safe
            rescue => e
              puts "--- ACTUAL ERROR ---"
              puts e.message
              puts "--------------------"
            end
        else
          puts "<<<<<<<<<<< #{method_name} not recognised"
          return super
        end       
      end

      def respond_to_missing?(method_name, include_private = false)
        method_name.to_s.start_with?('govuk') || super
      end
    end
  end
end
::Middleman::Extensions.register(:your_design_system, YourDesignSystem::Extension)