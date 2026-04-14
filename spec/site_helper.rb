require "yaml"
require "tempfile"

module Helpers
module_function

  # Build the example site using middleman

  def tech_docs_config
    @tech_docs_config
  end

  def rebuild_site!(config: "config/tech-docs.yml", overrides: {})
    config_file = Tempfile.new("tech_docs_config")

    begin
      Dir.chdir("example") do
        @tech_docs_config = YAML.load_file(config).merge(overrides).freeze
        config_file.write(YAML.dump(tech_docs_config.to_h))
        config_file.close
        command = [
          "rm -rf build",
          "bundle install --quiet",
          "CONFIG_FILE=#{config_file.path} NO_CONTRACTS=true middleman build --bail --show-exceptions",
        ].join(" && ")
        unless system(command)
          raise "`middleman build` failed, see the log for more info"
        end
      end
    ensure
      config_file.unlink
    end
  end
end
