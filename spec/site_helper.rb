require "yaml"
require "tempfile"
require 'fileutils'
module Helpers
  module_function

  # Build the test site using middleman

  def tech_docs_config
    @tech_docs_config
  end

  def rebuild_site!(config: "config/tech-docs.yml", overrides: {})
    Dir.chdir("spec/test-site") do
      @tech_docs_config = YAML.load_file(config).merge(overrides).freeze

      build_exists = Dir.exist?("build")
      config_changed = ($last_build_config != @tech_docs_config)

      if build_exists && !config_changed
        puts "New build not required"
        return
      end

      config_file = Tempfile.new("config")
      max_retries = 3
      retries = 0

      begin
        config_file.write(YAML.dump(tech_docs_config.to_h))
        config_file.close

        # 1. Clear the old build directory (with a rescue in case it's temporarily locked)
        if Dir.exist?("build")
          trash_path = "build_trash_#{Time.now.to_f}"
          begin
            File.rename("build", trash_path)
            FileUtils.rm_rf(trash_path)
          rescue StandardError
            FileUtils.rm_rf("build") rescue nil
          end
        end

        # 2. Command WITHOUT the npm install line.
        # We rely on Middleman's --clean flag to handle leftover artifacts
        command = [
          "bundle check || bundle install --quiet",
          "CONFIG_FILE=#{config_file.path} NO_CONTRACTS=true middleman build --clean --bail --show-exceptions"
        ].join(" && ")

        # 3. Execute with Retry Logic
        unless system(command)
          raise "Middleman build shell command failed"
        end

        # Cache the successful config
        $last_build_config = @tech_docs_config

      rescue StandardError => e
        retries += 1
        if retries <= max_retries
          puts "\n Build hiccup detected (likely a ghost process). Waiting 1.5s... (Retry #{retries}/#{max_retries})"
          sleep 1.5

          # Re-open the config file for the next attempt if it was closed
          config_file = Tempfile.new("config") if config_file.closed?
          retry
        else
          raise "`middleman build` permanently failed after #{max_retries} attempts. Last error: #{e.message}"
        end
      ensure
        config_file.unlink unless config_file.nil? || config_file.closed?
      end
    end
  end
end
