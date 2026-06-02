# Rakefile
require 'json'
require 'open3'
require 'set'

desc "Run tech-docs-linter to check content against GOV.UK style guide. "

namespace :lint do
  task :vale, [:target, :clean_build] do |t, args|
    args.with_defaults(target: "./build", clean_build: false)

    # Helper to print the raw JSON blocks for downstream CI consumption
    def output_summary_table(error, warning, suggestion)
      puts "\n" + "=" * [0, 40].max
      puts "\e[1m Vale summary\e[0m"
      puts "=" * [0, 40].max
      puts "  Errors:      #{error > 0 ? colorize(error, 'error') : error}"
      puts "  Warnings:    #{warning > 0 ? colorize(warning, 'warning') : warning}"
      puts "  Suggestions: #{suggestion > 0 ? colorize(suggestion, 'suggestion') : suggestion}"
      puts "-" * [0, 40].max
    end
    # Color Escape Helper
    def colorize(text, severity)
      case severity.downcase
      when 'error' then "\e[31m#{text}\e[0m" # Red
      when 'warning' then "\e[33m#{text}\e[0m" # Yellow
      when 'suggestion' then "\e[34m#{text}\e[0m" # Blue
      else "\e[36m#{text}\e[0m" # Cyan
      end
    end

    def get_table_rows_from_json(report_json)
      unique_linter_results = []
      widths = { file: 9, line: 4, severity: 8, message: 7, rule: 7 }

      report_json.each do |file_path, alerts|
        next if alerts.empty?
        seen_messages = Set.new

        alerts.each do |alert|
          msg = alert['Message']
          # --- DEDUPLICATION LOGIC ---
          if seen_messages.include?(msg) && alert['Check'].downcase == "tech-writing-style-guide.acronyms"
            next
          end
          seen_messages.add(msg)
          # ---------------------------

          row_data = {
            file: file_path,
            line: alert['Line'].to_s,
            severity: alert['Severity'],
            message: msg,
            rule: alert['Check']
          }
          unique_linter_results << row_data
        end
      end
      return unique_linter_results
    end

    def get_table_column_widths(rows)
      # Compute widths once
      [:file, :line, :severity, :message, :rule].each_with_object({}) do |col, acc|
        all_values = rows.map { |row| row[col].to_s }
        acc[col] = [col.to_s.length, *all_values.map(&:length)].max
      end

    end

    def get_severity_totals_from_rows(rows)
      totals = { 'error' => 0, 'warning' => 0, 'suggestion' => 0 }

      totals.merge(
        rows
          .map { |r| r[:severity] }
          .compact   # drops any actual nils
          .tally
      )
    end

    def output_formatted_row(format, severity_width, row)

      colored_severity = colorize(row[:severity].upcase, row[:severity])
      severity_padding = " " * (severity_width - row[:severity].length)
      padded_severity = "#{colored_severity}#{severity_padding}"

      puts sprintf(
             format,
             row[:file], row[:line], padded_severity, row[:message], row[:rule]
           )

    end

    def output_detail_table(stdout_output)
      begin
        rows = get_table_rows_from_json(JSON.parse(stdout_output))
        totals = get_severity_totals_from_rows(rows)

        if rows.empty?
          puts "\e[32m✨ Vale Style Check: All duplicate errors filtered out. Clear skies!\e[0m"
        else

          # 1. Print the human-readable terminal table
          widths = get_table_column_widths(rows)
          format = "%-#{widths[:file]}s | %-#{widths[:line]}s | %-#{widths[:severity]}s | %-#{widths[:message]}s | %s"
          header = sprintf(format, "File", "Line", "Severity", "Message", "Rule")

          puts "\e[1m🔍 Vale Style Linting Report\e[0m\n\n"
          puts "\e[1m#{header}\e[0m"
          puts "-" * header.length

          rows.each do |row|
            output_formatted_row(format, widths[:severity], row)
          end
          # 3. Hand over the raw numbers for CI evaluation
          output_summary_table(totals['error'], totals['warning'],totals['suggestion'])
        end

      rescue JSON::ParserError
        puts "\e[Error parsing Vale payload:\e[0m\n#{stdout}"
        exit 1
      end

    end

    if args.clean_build == "true"
        Rake::Task["middleman:build"].invoke
    end

    stdout, stderr, status = Open3.capture3("vale --output=JSON #{args.target}")

    if stdout.strip.empty?
      puts "\e[32m✨ Vale Style Check: No errors found!\e[0m"
      output_summary_table(0, 0, 0 )
    else
      output_detail_table(stdout)
    end
    exit 0 # Always exit 0 so individual project pipelines can evaluate the data themselves

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
