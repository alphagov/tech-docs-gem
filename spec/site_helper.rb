require "yaml"
require "tempfile"

module Helpers
module_function

  # Build the example site using middleman

  def rebuild_site!(config: "config/tech-docs.yml", overrides: {})
    config_file = Tempfile.new("tech_docs_config")

    begin
      Dir.chdir("example") do
        new_config = YAML.load_file(config).merge(overrides)
        config_file.write(YAML.dump(new_config))
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
