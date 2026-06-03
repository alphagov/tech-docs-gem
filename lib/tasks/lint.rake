# Rakefile
require 'json'
require 'open3'
require 'set'
require_relative "./helpers/vale_report"


desc "Run tech-docs-linter to check content against GOV.UK style guide."
namespace :lint do

  # task vale_sync:
  
  task :vale, [:target, :clean_build, :full_output] do |t, args|
    args.with_defaults(target: "./build", clean_build: "true", full_output: "true")

    if args.clean_build == "true"
        Rake::Task["middleman:build"].invoke
    end

    stdout, stderr, status = Open3.capture3("vale --output=JSON #{args.target}")

    linter_report = ValeLinterReport.new(stdout)
    linter_report.format_linter_output
    if "true" == args.full_output
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
     task :build do
        if Dir.exist?("./build")
            puts "Target directory found at ./build.  Removing old build."
            FileUtils.rm_rf("./build")
        end
        sh "bundle exec middleman build"
     end
 end
