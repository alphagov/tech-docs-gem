require 'middleman-core'

module YourDesignSystem
  class Extension < Middleman::Extension
    def initialize(app, options_hash={}, &block)
      super
    end

    helpers do 
      def method_missing(method_name, *args, &block)
        case
          when method_name.to_s.start_with?('govuk')
            begin
              data = args.first || {}
              @renderer ||= YourDesignSystem::NunjucksRenderer.new(File.expand_path('../../', __dir__))
              @renderer.render_govuk_component(method_name, data).html_safe
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