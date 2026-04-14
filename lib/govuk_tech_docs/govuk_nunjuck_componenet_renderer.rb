require "schmooze"

module GovukTechDocs
  class GovukNunjuckComponenetRenderer < Schmooze::Base
    dependencies nunjucks: "nunjucks"

    def initialize(gem_root)
      super(gem_root) # Pass it up to Schmooze so it finds node_modules
      @gem_root = gem_root
    end

    method :render_nunjucks_template, <<~JS
      (templateString, templateData, searchPaths) => {
          const env = nunjucks.configure(searchPaths, { autoescape: true });
          return env.renderString(templateString, templateData);
      }
    JS

    def get_component_template_name(component_name)
      component_name.to_s.delete_prefix("govuk")
                  .gsub(/([A-Z]+)([A-Z][a-z])/, '\1-\2') # Handle acronyms like "JSONData"
                  .gsub(/([a-z\d])([A-Z])/, '\1-\2')     # Handle standard "CamelCase"
                  .downcase
    end

    def render_govuk_component(component_name, template_data)
      # 1. Logic for search paths belongs here now

      search_paths = [File.join(@gem_root, "node_modules/govuk-frontend/dist")]
      component_template_name = get_component_template_name(component_name)
      # 2. Call the JS method defined above
      nunjucks_template_string = <<~NJK
              {% from "govuk/components/#{component_template_name}/macro.njk" import #{component_name} %}
              {{ #{component_name}(template_data) }}
      NJK
      render_nunjucks_template(nunjucks_template_string, { "template_data" => template_data }, search_paths)
    # rubocop:disable Lint/UselessAssignment
    rescue StandardError => e 
      raise "Could not load GOV.UK component #{component_name} with data #{template_data}."
    end
    # rubocop:enable Lint/UselessAssignment
  end
end
