# Rakefile
require "json"
require "timeout" # Built into standard Ruby
require_relative "./helpers/rake_utils"
require_relative "./helpers/vale_report"

namespace :lint do
  desc "Run linter to check content against GOV.UK style guide."
  task :vale, [:target, :clean_build, :full_output] do |_t, args|
    args.with_defaults(target: "./build", clean_build: "true", full_output: "true")

    # sh "bundle exec vale sync --config='#{vale_config_path}'"
    Rake::Task["middleman:build"].invoke if args.clean_build == "true"

    files = Dir.glob("#{args.target}/**/*.{html,md}")
    puts "Running Vale against #{files.count} files...\n\n"

    combined_json = {}

    files.each do |file|
      print "Linting #{file}... "

      file_output = ""

      # IO.popen runs the command and exposes the Process ID (PID)
      IO.popen(["vale", "--config=#{vale_config_path}", "--output=JSON", file]) do |io|
        begin
          # If a file takes longer than 10 seconds, raise a timeout
          Timeout.timeout(10) do
            file_output = io.read
          end
          # If we reach here, it finished safely
          puts "\e[32mDone\e[0m"
        rescue Timeout::Error
          # The regex hung. Send a SIGKILL to the Vale process to stop it chewing CPU
          Process.kill("KILL", io.pid)
          puts "\e[31mHUNG (Skipped due to timeout)\e[0m" # Red text
        end
      end

      # Merge JSON only if we got a valid response (ignores timeouts)
      unless file_output.strip.empty?
        parsed_output = JSON.parse(file_output)
        combined_json.merge!(parsed_output) unless parsed_output.empty?
      end
    end

    puts "\nGenerating report..."

    linter_report = ValeLinterReport.new(combined_json.to_json)
    linter_report.format_linter_output

    puts linter_report.get_linter_full_report if args.full_output == "true"
    puts linter_report.get_linter_summary_report

    linter_report.linter_summary_report_json
    exit 0
  end

  desc "Debug Vale to find which rule hangs on a specific file."
  task :debug do

    style_prefix = 'tech-writing-style-guide'
    target_file = './build/search/index.html'

    # ADD YOUR RULE NAMES HERE (without the style prefix or .yml extension)
    rules = [
      "acronyms", "brackets-in-headings", "common-misspellings","H4", "H5", "H6", "headings-length", "multiple-h1-tags",
      "sentence-length","terminal-punctuation","words-to-avoid","words-to-avoid-unless",
      "skipped-heading-levels",
      "consecutive-headings",
      "headings-with-no-content"
    ]

    puts "Hunting for the hanging regex in #{target_file}...\n\n"

    rules.each do |rule_name|
      full_rule = "#{style_prefix}.#{rule_name}"
      print "Testing #{full_rule}... "
      filter_string = ".Name=='#{full_rule}'"

      # Run Vale for just this single rule
      IO.popen(["vale", "--filter=#{filter_string}", "--output=line", target_file]) do |io|
        begin
          # If the regex loops catastrophically, it hits this 5-second limit
          Timeout.timeout(5) do
            io.read
          end

          # If it finishes within 5 seconds, the rule is safe
          puts "\e[32mPassed (No hang)\e[0m"

        rescue Timeout::Error
          # The regex froze! Kill the underlying process to save CPU and flag it
          Process.kill("KILL", io.pid)
          puts "\e[31m💥 HUNG! (This is the broken regex)\e[0m"
        end
      end
    end

    exit 0
  end

end
