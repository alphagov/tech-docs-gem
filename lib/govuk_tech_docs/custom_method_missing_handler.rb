require "middleman-core"

module GovukTechDocs
  class CustomMethodMissingHandler < Middleman::Extension
    def initialize(app, options_hash = {}, &block)
      super
    end

    helpers do
      def method_missing(method_name, *args, &block)
        if method_name.to_s.start_with?("govuk")
          begin
            data = args.first || {}
            @renderer ||= GovukTechDocs::GovukNunjuckComponenetRenderer.new(File.expand_path("../../", __dir__))
            @renderer.render_govuk_component(method_name, data).html_safe
          rescue StandardError => e
            raise e.to_s.to_s
          end
        else
          super
        end
      end

      def respond_to_missing?(method_name, include_private = false)
        method_name.to_s.start_with?("govuk") || super
      end
    end
  end
end
::Middleman::Extensions.register(:custom_method_missing_handler, GovukTechDocs::CustomMethodMissingHandler)
