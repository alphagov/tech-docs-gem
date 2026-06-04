# Rakefile
require "json"
require "open3"
require_relative "./helpers/vale_report"

namespace :lint do
  # task vale_sync:
  desc "Run tech-docs-linter to check content against GOV.UK style guide."
  task :vale, [:target, :clean_build, :full_output] do |_t, args|
    args.with_defaults(target: "./build", clean_build: "true", full_output: "true")

    if args.clean_build == "true"
      Rake::Task["middleman:build"].invoke
    end

    stdout, = Open3.capture3("vale --output=JSON #{args.target}")

    linter_report = ValeLinterReport.new(stdout)
    linter_report.format_linter_output
    if args.full_output == "true"
      puts linter_report.get_output_detail
    end
    puts linter_report.get_output_summary

    # finish with a Ci friendly json string
    linter_report.get_output_summary_json
    # Always exit 0 so individual project pipelines can evaluate the data themselves
    exit 0
  end
end

namespace :middleman do
  desc "Delete build directory and run bundle exec middleman build"
  task :build do
    if Dir.exist?("./build")
      puts "Target directory found at ./build.  Removing old build."
      FileUtils.rm_rf("./build")
    end
    sh "bundle exec middleman build"
  end
end
